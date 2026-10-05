%define lr.type pslr
%define api.pslr.state-member pslr_current_state

/* Reduced reproducer for the unresolved tLABEL PSLR inadequacy.
 * The core shape is:
 * - user_variable feeds both primary and lhs
 * - command_args can continue into a label context
 * - lhs '=' arg provides a non-label path for the same merged core
 */

%token tIDENTIFIER "identifier"
%token tLABEL "label"
%token tEQL "="
%token-pattern tIDENTIFIER /[a-z_][a-zA-Z0-9_]*/
%token-pattern tLABEL /[a-z_][a-zA-Z0-9_]*:/

%%

program
    : command
    | arg
    ;

command
    : user_variable command_args
    ;

arg
    : asgn_arg_rhs
    | primary
    ;

primary
    : user_variable
    ;

command_args
    : arg
    | arg label_body
    | label_body
    ;

user_variable
    : tIDENTIFIER
    ;

lhs
    : user_variable
    ;

asgn_arg_rhs
    : lhs tEQL arg
    ;

label_body
    : tLABEL
    ;
