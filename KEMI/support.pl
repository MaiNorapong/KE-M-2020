:- module(support,[get_neutral_specie/2,multiplicative_prefix/2,mul_prefix_except_mono/2]).
:- use_module(utils,[split_decimal/3,split_digits/2]).
:- use_module(ustr,[join/3]).
:- use_module(ulist,[enumerate/2,range/4]).
:- use_module(facts,[multiplicative_prefix_fact/2,multiplicative_affix_fact/2,complex_multiplicative_prefix_fact/2]).
:- use_module(ustr,[remove_chars/3]).


%!	multiplicative_prefix(+Number:int, +Prefix:string) semidet.
%!	multiplicative_prefix(+Number:int, -Prefix:string) semidet.
%!	multiplicative_prefix(-Number:int, -Prefix:string) multi.
%!	multiplicative_prefix(-Number:int, +Prefix:string) semidet.
%
%   True when `Prefix` is the multiplicative prefix of `Number`.
%
%   @arg Number Integer between 1 and 9999.
%
multiplicative_prefix(Number, Prefix) :-
    var(Number), nonvar(Prefix) ->
        multiplicative_prefix_(Number, Prefix), !;
    multiplicative_prefix_(Number, Prefix).
multiplicative_prefix_(Number, Prefix) :-
    between(1, 9999, Number),
    (
        multiplicative_prefix_fact(Number, Prefix_) -> true;
        gen_mul_prefix(Number, Prefix_)
    ),
    Prefix = Prefix_.

gen_mul_prefix(Number, Prefix) :-
    Number = 0 -> Prefix = "";
    multiplicative_affix_fact(Number, Prefix) -> true;
    nonvar(Number),
    split_decimal(Number, First, Rest),
    get_affix(First, CurrentPart),
    gen_mul_prefix(Rest, RecursePart),
    string_concat(RecursePart, CurrentPart, Prefix).

%!  get_affix(+Number, +Affix) is semidet.
%!  get_affix(+Number, -Affix) is semidet.
%!  get_affix(-Number, -Affix) is ERROR.
%!  get_affix(-Number, +Affix) is semidet.
%
%   True when `Number` is a number with the form "[1-9]0*" and `Affix` is its generated affix
%   OR when affix is found in fact.
%
get_affix(Number, Affix) :-
    multiplicative_affix_fact(Number, Affix) -> true;
    gen_affix_(Number, Affix), !.

%!  gen_affix_(+Number, +Affix) is semidet.
%!  gen_affix_(+Number, -Affix) is semidet.
%!  gen_affix_(-Number, -Affix) is ERROR.
%!  gen_affix_(-Number, +Affix) is ERROR.
%
%   True when `Number` is a number with the form "[1-9]0*" and `Affix` is its generated affix.
%
gen_affix_(Number, Affix) :-
    split_digits(Number, [Num|T]),
    forall(member(E, T), E =:= 0),
    length(T, NumZeroes),
    multiplicative_affix_fact(Num, Affix_),
    (
        NumZeroes = 1 -> string_concat(Affix_, "conta", Affix);
        NumZeroes = 2 -> string_concat(Affix_, "cta", Affix);
        NumZeroes = 3 -> string_concat(Affix_, "lia", Affix)
    ).


%!	complex_multiplicative_prefix(+Number, +Prefix) semidet.
%!	complex_multiplicative_prefix(+Number, -Prefix) det.
%!	complex_multiplicative_prefix(-Number, -Prefix) det.        # TODO: Fix (returns first fact)
%!	complex_multiplicative_prefix(-Number, +Prefix) failure.    # TODO: FIx
%
%   Note: Depends on multiplicative_prefix/2.
%
complex_multiplicative_prefix(Number, Prefix) :-
    complex_multiplicative_prefix_fact(Number, Prefix) -> true;
    multiplicative_prefix(Number, SimplePrefix),
    string_concat(SimplePrefix, "kis", Prefix).


%!	mul_prefix_except_mono(+Number, +Prefix) semidet.
%!	mul_prefix_except_mono(+Number, -Prefix) det.
%!	mul_prefix_except_mono(-Number, -Prefix) det.       # TODO: Fix (returns first fact)
%!	mul_prefix_except_mono(-Number, +Prefix) failure.   # TODO: FIx
%
%   Note: Depends on multiplicative_prefix/2.
%
mul_prefix_except_mono(Number, Prefix) :-
    Number = 1 -> Prefix = "";
    multiplicative_prefix(Number, Prefix).


%!  get_neutral_specie(+Formula: string, -NeutralSpecie: string) is det.
%!  get_neutral_specie(+Formula: string, +NeutralSpecie: string) is semidet.
%!  get_neutral_specie(-Formula: string, +NeutralSpecie: string) is ERROR.
%
%   Get neutral specie (element without charge) from `Formula`
%   Note: Need parentheses to separate compound and charge
%     examples [N2H5]+, [Cl]-
%
get_neutral_specie(Formula, NeutralSpecie) :-
    re_matchsub("^[+-]?([1-9][0-9]*)?(?<formula>.*?)([1-9][0-9]*)?[+\\-]?$", Formula, SubDict, []),
    get_dict(formula, SubDict, Formula_),
    remove_chars(Formula_, "()[]{}", NeutralSpecie).
