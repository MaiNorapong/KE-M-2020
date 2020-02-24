/* 
    Facts

*/
:- module(elements,[element_quantity/2, extract_elements_from_formula/2, halogen/1]).
:- use_module(utils, [extract_term/2]).
:- use_module(facts, [en/2, num_protons/2, element_name/2]).

%
%
% TODO: validate each element
%

halogen(fluorine).
halogen(chlorine).
halogen(bromine).
halogen(iodine).
halogen(astatine).

element_quantity(Symbol, Quantity) :-
    Quantity > 0,
    element_name(Symbol, _).
    
formula_to_quantified(Raw, Elements) :-
    re_split("([1-9][0-9]*)"/n, Raw, [RawSymbol, Quantity|_], []),
    element_name(Symbol, _),
    Elements =.. [element_quantity, Symbol, Quantity],
    call(Elements),
    atom_string(RawSymbol, Symbol).

extract_elements_from_formula(Formula, Elements) :-
    extract_elements_(Formula, 0, "", Elements).

determine_multiplicity(Formula, Result) :- 
    formula_to_quantified(Formula, Result).

determine_multiplicity(Formula, Result) :- 
    Result =.. [element_quantity, Formula, 1],
    call(Result).
   

extract_elements_(Formula, Start, _, _) :-
    string_length(Formula, Length),
    Start = Length.

extract_elements_(Formula, Start, String, End) :-
    string_length(Formula, Length),
    Start < Length,
    Final is Length - 1 - Start,
    sub_string(Formula, Final, _, Start, Out),
    Trim is Start + 1,
    string_concat(Out, String, ConcatString),
    (
        is_upper(Out) -> 
        extract_elements_(Formula, Trim, "", End2); 
        extract_elements_(Formula, Trim, ConcatString, End2),
    !) ,
    (is_upper(Out) -> determine_multiplicity(ConcatString, Result), Sth = [Result]; Sth = []),
    append(End2, Sth, End).

%! period(+Element:string, -Period:integer) is det.
%! period(-Element:string, +Period:integer) is multi.
%
%  True if element Element is in period Period.
%
period(Element, Period) :-
    num_protons(Element, Z),
    (
        Z =<   2 -> Period is 1;
        Z =<  10 -> Period is 2;
        Z =<  18 -> Period is 3;
        Z =<  36 -> Period is 4;
        Z =<  54 -> Period is 5;
        Z =<  86 -> Period is 6;
        Z =< 118 -> Period is 7;
        Period is 8
    ).

delta(X, Y, R) :- 
    (
        X > Y -> R is X - Y;
        Y > X -> R is Y - X
    ).

%! delta_en(+Element1:string, +Element2:string, -Result:float) is det.
%! delta_en(-Element1:string, -Element2:string, +Result:float) is multi.
%
%  Compute delta EN between Element1 and Element2
%
delta_en(Element1, Element2, Result) :- 
    en(Element1, En1), 
    en(Element2, En2),
    delta(En1, En2, Result),
    !.
