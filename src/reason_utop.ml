(* Portions Copyright (c) 2015-present, Facebook, Inc. All rights reserved. *)

type top_kind = RTop | UTop
let current_top = ref RTop

let init_reason () =
  if List.exists ((=) "camlp4o") !Topfind.predicates ||
     List.exists ((=) "camlp4r") !Topfind.predicates then
    print_endline "Reason is incompatible with camlp4!"
  else begin
    current_top := RTop;
    UTop.set_phrase_terminator ";";
    UTop.prompt := fst (React.S.create LTerm_text.
                     (eval [B_fg (LTerm_style.green); S "Reason # "]));
    UTop.parse_toplevel_phrase := UTop.parse_default (
      Reason_util.correctly_catch_parse_errors
      Reason_toolchain.JS.canonical_toplevel_phrase
    );
    UTop.parse_use_file := UTop.parse_default (
      Reason_util.correctly_catch_parse_errors
      Reason_toolchain.JS.canonical_use_file
    );
    UTop.history_file_name :=
      Some (Filename.concat LTerm_resources.home ".rtop-history");

    Toploop.parse_use_file := Reason_util.correctly_catch_parse_errors
                                Reason_toolchain.JS.canonical_use_file;

    (* Printing in Reason syntax *)
    Toploop.print_out_value := Reason_oprint.print_out_value;
    Toploop.print_out_type := Reason_oprint.print_out_type;
    Toploop.print_out_class_type := Reason_oprint.print_out_class_type;
    Toploop.print_out_module_type := Reason_oprint.print_out_module_type;
    Toploop.print_out_type_extension := Reason_oprint.print_out_type_extension;
    Toploop.print_out_sig_item := Reason_oprint.print_out_sig_item;
    Toploop.print_out_signature := Reason_oprint.print_out_signature;
    Toploop.print_out_phrase := Reason_oprint.print_out_phrase;
  end

let init_ocaml () =
  current_top := UTop;
  UTop.set_phrase_terminator ";;";
  UTop.prompt := fst (React.S.create LTerm_text.
                   (eval[B_fg (LTerm_style.green); S "OCaml # "]));
  UTop.parse_toplevel_phrase := UTop.parse_toplevel_phrase_default;
  UTop.parse_use_file := UTop.parse_use_file_default;
  UTop.history_file_name :=
      Some (Filename.concat LTerm_resources.home ".utop-history")

let toggle_syntax () =
  match !current_top with
  | RTop -> init_ocaml ()
  | UTop -> init_reason ()

let _ =
  Hashtbl.add Toploop.directive_table "toggle_syntax"
    (Toploop.Directive_none toggle_syntax);
  init_reason ()
