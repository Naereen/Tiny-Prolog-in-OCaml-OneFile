(** OCaml source code of https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile
    (C) 2020 Lilian Besson
    MIT License, https://lbesson.mit-license.org/
*)

open Genlex;;
open Printf;;


(* lib.ml *)

let do_list f = List.fold_left (fun a b -> (f b)) ();; (* List.iter *)

let rec in_list x = function  (* List.mem *)
  | [] -> false
  | a::q -> a=x || (in_list x q)
;;

let rec filter l = function  (* List.filter *)
  | [] -> []
  | (x, t)::q -> if in_list x l then (filter l q) else (x, t)::(filter l q)
;;

let map = List.map;;

type term =
  | Var of string
  | Term of string * (term list);;

type clause = {pos : term; neg : term list};;

let rec print_terme = function
  | Var id -> id
  | Term (f, l) ->
    begin
      match l with
      | [] -> f
      | t::q ->
        sprintf "%s(%s%s)" f (print_terme t) (string_of_terme_list q)
    end
and string_of_terme_list l =
  match l with
  | [] -> ""
  | t::q -> sprintf ", %s%s" (print_terme t) (string_of_terme_list q)
;;

let print_clause cl =
  match cl.neg with
  | [] -> print_terme cl.pos
  | t::q ->
    (* sprintf "%s <-- %s%s)" (print_terme cl.pos) (print_terme t) (string_of_terme_list q) *)
    sprintf "%s :- %s%s)" (print_terme cl.pos) (print_terme t) (string_of_terme_list q)
;;


let lex = make_lexer ["<--"; ":-"; "("; ")"; ","; "."];;

let rec parse_term1 = parser
  | [< 'Ident f; t = parse_term2 f >] -> t
and parse_term2 f = parser
  | [< 'Kwd "("; t1 = parse_term1 ; l = parse_term_list; 'Kwd ")" >] -> Term (f, t1::l)
  | [< >] ->
    begin
      match f.[0] with
      | 'A'..'Z' -> Var f
      | _ -> Term (f,  [])
    end
and parse_term_list = parser
  | [< 'Kwd ","; t1 = parse_term1 ; l = parse_term_list >] -> t1::l
  | [<>] -> []
;;

let parse_goal1 = parser
  | [< t1 = parse_term1 ; l = parse_term_list >] -> t1::l;;

let parse_term s = parse_term1 (lex (Stream.of_string s));;

let parse_goal s = parse_goal1 (lex (Stream.of_string s));;

let rec parse_clause1 = parser
  | [< t = parse_term1; cl = parse_clause2 t >] -> cl
and parse_clause2 t = parser
  | [< 'Kwd "." >] -> {pos = t; neg = []}
  | [< 'Kwd ":-"; t1 = parse_term1; l = parse_term_list; 'Kwd "." >] -> {pos = t; neg = t1::l}
  | [< 'Kwd "<--"; t1 = parse_term1; l = parse_term_list; 'Kwd "." >] -> {pos = t; neg = t1::l}
;;

let parse_clause s = parse_clause1 (lex (Stream.of_string s));;

let print_subst l =
  let rec aux = function
    | [] -> ""
    | (x, t)::q -> sprintf ",  %s = %s%s" x (print_terme t) (aux q)
  in
  match l with
  | [] -> "{ }"
  | (x, t)::q ->
    sprintf "{ %s = %s%s }" x (print_terme t) (aux q)
;;

let rec parse_prog_parser acc = parser
  | [< cl = parse_clause1 ; res = parse_prog_parser acc >] -> cl::res
  | [<>] -> acc
;;

let rec read_all_lines_rec acc filter input_channel =
  try
    let line = input_line input_channel in
    if filter line then
      read_all_lines_rec (line :: acc) filter input_channel
    else
      read_all_lines_rec acc filter input_channel
  with End_of_file -> acc
;;
let read_all_lines filter input_channel = read_all_lines_rec [] filter input_channel;;

let is_not_comment s =
  not (String.contains s '#')
;;

let parse_prog acc f =
  let file = open_in f in
  (* let flx = Stream.of_channel file in
  parse_prog_parser acc (lex flx) *)
  (* hack to open the file, read, remove lines starting with #? *)
  let lines = read_all_lines is_not_comment file in
  let one_huge_line = ref "" in
  List.iter (fun line -> one_huge_line := !one_huge_line ^ line) lines;
  let flx3 = Stream.of_string (!one_huge_line) in
  parse_prog_parser acc (lex flx3)
;;

let parse_progs l =
  List.fold_left parse_prog [] l
;;

let fresh num cl =
  let rec aux = function
    | Var x -> Var (sprintf "%s_%i" x num)
    | Term (f, l) -> Term (f, map aux l)
  in
  {pos = aux cl.pos; neg = map aux cl.neg}
;;

let rec yesOrNo mess =
  print_string mess;
  print_string " (y/n) [y] : ";
  match (read_line ()) with
  | "y" -> true
  | "o" -> true
  | ""  -> true
  | "n" -> false
  | _   -> print_string "\n"; yesOrNo mess
;;

let display_subst s =
  printf "  %s\n" (print_subst s)
;;


(* resolution.ml *)

let rec subst x t trm =
  match trm with
  | Var p -> if p=x then t else trm
  | Term (f, l) -> Term (f, map (subst x t) l)
;;

let rec app_subst l trm =
  match l with
  | [] -> trm
  | (x, t)::q -> (app_subst q (subst x t trm))
;;

let subst_on_couple x t = function (p, trm) -> (p, subst x t trm);;

let rec apply_subst_on_subst s1 s2 =
  match s1 with
  | [] -> s2
  | (x, t)::q -> (apply_subst_on_subst q (map (subst_on_couple x t) s2))
;;

let vars_subst = map fst;;

let rec compose l1 l2 = (filter (vars_subst l2) l1) @ (apply_subst_on_subst l1 l2);;

let rec occurence x = function
  | Var y -> x=y
  | Term (f, l) -> occurence_list x l
and occurence_list x = function
  | [] -> false
  | t::q -> (occurence x t) || (occurence_list x q)
;;

let rec unification t1 t2 =
  match (t1, t2) with
  | (Var x), (Var y) ->
    if x=y then true, []
    else true, [x, Var y]
  | (Var x), t ->
    if (occurence x t) then false, []
    else true, [x, t]
  | t, (Var x) ->
    if (occurence x t) then false, []
    else true, [x, t]
  | (Term (f1, l1)), (Term (f2, l2)) ->
    if f1=f2 then unification_list l1 l2
    else false, []
and unification_list l1 l2 =
  match (l1, l2) with
  | [], [] -> true, []
  | [], _  -> false, []
  | _ , [] -> false, []
  | t1::q1, t2::q2 ->
    let (b1, s1) = unification t1 t2 in
    if b1 then
      let (b2, s2) = (unification_list
                     (map (app_subst s1) q1)
                     (map (app_subst s1) q2)) in
      if b2 then true, (compose s2 s1)
      else false, []
    else false, []
;;

let rec search_clauses num prog trm =
  match prog with
    [] -> []
  | cl::q ->
    let fresh_cl = fresh num cl in
    let (b, s) = unification trm fresh_cl.pos in
    if b then (s, fresh_cl)::(search_clauses num q trm)
    else (search_clauses num q trm)
;;

let rec prove_goals_rec ?(maxoutput=10) ?(interactive=true) but num prog s = function
  | [] ->
    display_subst (List.filter (fun (v, _) -> occurence_list v but) s);
    if interactive then begin
      if not (yesOrNo "continue ?") then
        failwith "end"
    end;
    if maxoutput = 0 then failwith "end";
  | trm::q ->
    let ssButs = search_clauses num prog trm in
    begin
      do_list
        (fun (s2, cl) ->
           (prove_goals_rec ~maxoutput:(maxoutput-1) ~interactive:interactive but (num+1) prog
              (compose s2 s)
              (map (app_subst s2) (cl.neg @ q))))
        ssButs
    end
;;

let prove_goals ?(maxoutput=10) ?(interactive=true) prog trm_list =
  try
    prove_goals_rec ~maxoutput:maxoutput ~interactive:interactive trm_list 0 prog [] trm_list
  with
    Failure "end" -> ()
;;


(* prolog.ml *)

let nbarg = Array.length Sys.argv in
let listargv = List.tl (Array.to_list Sys.argv) in

if nbarg >= 2 then begin
  if nbarg >= 3 then begin
    let rev_listargv = List.rev listargv in
    let progs = List.rev (List.tl rev_listargv)
    and fake_read_line = List.hd rev_listargv in
    printf "?- %s\n" fake_read_line;
    let prog = parse_progs progs in
    let trm_list = parse_goal fake_read_line in
    prove_goals ~interactive:false prog trm_list
  end else begin
    let prog = parse_progs listargv in
    printf "?- ";
    let trm_list = parse_goal (read_line ()) in
    prove_goals ~interactive:true prog trm_list
  end
end;;
