:- module(icompositional,[boron_hydride_stoichiometric/2,general_stoichiometric/2,addition_compound_cn/2,ion_cn/2,binary_compound_cn/2,homonuclear_cn/2]).
:- use_module(uchem,[get_element/3,get_all_elements/2,get_num_atoms/3]).
:- use_module(elements,[element_name/2,group/2]).
:- use_module(support,[multiplicative_prefix/2,mul_prefix_except_mono/2]).


homonuclear_cn(Formula, Name) :-
    homonuclear(Formula),
    get_all_elements(Formula, Elements),
    memberchk(Element, Elements),
    get_num_atoms(Formula, Element, Amount),
    element_name(Element, ElementName),
    (
        group(Element, 18) -> mul_prefix_except_mono(Amount, MulPrefix);
        multiplicative_prefix(Amount, MulPrefix)
    ),
    string_concat(MulPrefix, ElementName, Name).
 
homonuclear(Formula) :-
    get_all_elements(Formula, Elements),
    length(Elements,1).

binary_compound_cn(Formula, Name) :-
    fail.


ion_cn(Formula, Name) :-
    cation_cn(Formula, Name);
    anion_cn(Formula, Name).

cation_cn(Formula, Name) :-
    monoatomic_cation_cn(Formula, Name);
    homopolyatomic_cation_cn(Formula, Name).

monoatomic_cation_cn(Formula, Name) :-
    fail.

homopolyatomic_cation_cn(Formula, Name) :-
    fail.

anion_cn(Formula, Name) :-
    monoatomic_anion_cn(Formula, Name);
    homopolyatomic_anion_cn(Formula, Name).

monoatomic_anion_cn(Formula, Name) :-
    fail.

homopolyatomic_anion_cn(Formula, Name) :-
    fail.


addition_compound_cn(Formula, Name) :-
    fail.

general_stoichiometric(Formula, Name) :-
    fail.
boron_hydride_stoichiometric(Formula, Name) :-
    fail.
