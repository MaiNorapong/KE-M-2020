:- module(icompositional,[boron_hydride_stoichiometric/2,general_stoichiometric/2,addition_compound_cn/2,ion_cn/2,binary_compound_cn/2,homonuclear_cn/2]).
:- use_module(uchem,[get_element/3,get_all_elements/2,get_num_atoms/3,get_net_charge/2]).
:- use_module(elements,[element_name/2,group/2]).
:- use_module(support,[get_neutral_specie/2,multiplicative_prefix/2,mul_prefix_except_mono/2]).


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

cation(Formula) :-
    get_net_charge(Formula, NetCharge),
    NetCharge > 0.

monoatomic(Formula) :-
    get_all_elements(Formula, Elements),
    length(Elements, 1),
    Elements = [Element0|_],
    get_neutral_specie(Formula, Formula_),        % TODO: remove this when `get_num_atoms()` finished
    % Still bug when Formula has 1 letter
    get_num_atoms(Formula_, Element0, NumAtom),
    NumAtom = 1.

cation_cn(Formula, Name) :-
    monoatomic_cation_cn(Formula, Name);
    homopolyatomic_cation_cn(Formula, Name).

%!  monoatomic_cation_cn(+Formula: string, -Name: string) is multi.
%!  monoatomic_cation_cn(+Formula: string, +Name: string) is det.
%!  monoatomic_cation_cn(-Formula: string, +Name: string) is ERROR.
%
%   IR-5.3.2.2
%   True if `Name` is a compositional name of `Formula`
%
monoatomic_cation_cn(Formula, Name) :-
    (
        monoatomic(Formula), cation(Formula)
    ),
    nonvar(Name) -> monoatomic_cation_cn_(Formula, Name);
    get_element(Formula, 0, Element),
    element_name(Element, ElementName),
    get_net_charge(Formula, NetCharge),
    string_concat("(", NetCharge, ChargeStr1),
    string_concat(ChargeStr1, "+)", ChargeStr2),
    string_concat(ElementName, ChargeStr2, Name).
% monoatomic_cation_cn("[Na]+", "sodium(1+)")
monoatomic_cation_cn_(Formula, Name) :-
    get_element(Formula, 0, Element),
    element_name(Element, ElementName),
    get_net_charge(Formula, NetCharge),
    string_concat("(", NetCharge, ChargeStr1),
    string_concat(ChargeStr1, "+)", ChargeStr2),
    string_concat(ElementName, ChargeStr2, Name),
    !.

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
