:- module(icompositional,[
    boron_hydride_stoichiometric_name/2,
    general_stoichiometric_name/2,
    addition_compound_cn/2,
    ion_cn/2,
    binary_compound_cn/2,
    homonuclear_cn/2
    ]).

:- use_module(nomenclature,[iupac_name/2]).
:- use_module(inorganic,[additive_name/2,substitutive_name/2,compositional_name/2]).
:- use_module(elements,[element_name/2,element_symbol/2,group/2]).
:- use_module(ialternative,[alternative_name/2]).

:- use_module(facts).
:- use_module(support).
:- use_module(uchem).
:- use_module(ucollections).
:- use_module(unums).
:- use_module(ustr).


ion(Formula) :- cation(Formula) -> true; anion(Formula).

cation(Formula) :-
    get_net_charge(Formula, NetCharge),
    NetCharge > 0.

anion(Formula) :-
    get_net_charge(Formula, NetCharge),
    NetCharge < 0.

monoatomic(Formula) :-
    count_atoms(Formula, Atoms),
    length(Atoms, 1),
    nth0(0, Atoms, _Element-Amount),
    Amount is 1.

homopolyatomic(Formula) :-
    count_atoms(Formula, Atoms),
    length(Atoms, 1),
    nth0(0, Atoms, _Element-Amount),
    Amount > 1.

heteropolyatomic(Formula) :-
    count_atoms(Formula, Atoms),
    length(Atoms, X),
    X > 1.


get_charge_str(Formula, ChargeStr) :-
    get_net_charge(Formula, NetCharge),
    (
        NetCharge > 0 -> get_ion_part_(NetCharge, "+", ChargeStr);
        NetCharge < 0 -> get_ion_part_(NetCharge, "-", ChargeStr);
        NetCharge = 0 -> fail
    ).

get_ion_part_(NetCharge, IonSign, ChargeStr) :-
    abs(NetCharge, NC),
    string_concat("(", NC, ChargeStr1),
    string_concat(ChargeStr1, IonSign, ChargeStr2),
    string_concat(ChargeStr2, ")", ChargeStr).


% # IR-5.2 p.81
% # IR-3.4.3 p.61
% # S8 ⇒ octasulfur

%!  homonuclear_cn(+Formula:string, +Name:string) is semidet.
%!  homonuclear_cn(+Formula:string, -Name:string) is semidet.
%!  homonuclear_cn(-Formula:string, -Name:string) is multi.
%!  homonuclear_cn(-Formula:string, +Name:string) is semidet.
%
%   True when `Name` is a compostional homonuclear name for the homonuclear 
%   compound represented by `Formula`. False otherwise.
%
%   @arg Formula – the chemical formula of the homonuclear molecule
%   @arg Name –  the stoichiometric name of the homonuclear molecule
%
homonuclear_cn(Formula, Name) :-
    nonvar(Name) ->
        homonuclear_name_atom(Name, Atom),
        homonuclear_formula_atom(Formula, Atom);
    homonuclear_formula_atom(Formula, Atom),
    homonuclear_name_atom(Name, Atom),
    % chcek formula
    homonuclear(Formula),
    not(ion(Formula)).


%!  homonuclear_name_atom(?Name:string, ?Element:atom, ?Amount:int) is det/multi.
%
%   True when `Atom = Element-Amount` is the atoms in the formula representted by `Name`.
%   False when `Name` is not a compositional homonuclear compound name.
%
homonuclear_name_atom(Name, Element-Amount) :-
    nonvar(Name) ->
        homonuclear_name_atom_(Name, Element-Amount), !;
    nonvar(Element), nonvar(Amount) ->
        homonuclear_name_atom_(Name, Element-Amount), !;
    homonuclear_name_atom_(Name, Element-Amount).

homonuclear_name_atom_(Name, Element-Amount) :-
    between(1, 9999, Amount),
    (
        element_name(Element, ElementName);
        alternative_element_name(Element, ElementName)
    ),
    (
        Amount = 1, group(Element, 18) -> MulPrefix = "";
        multiplicative_prefix(Amount, MulPrefix)
    ),
    string_concat(MulPrefix, ElementName, Name).

%!  homonuclear_formula_atom(?Formula:string, ?Element:atom, ?Amount:int) is det/multi.
%
homonuclear_formula_atom(Formula, Element-Amount) :-
    nonvar(Formula) ->
        split_term(Formula, Symbol, Amount),
        element_symbol(Element, Symbol);
    between(1, infinite, Amount),
    element_symbol(Element, Symbol),
    split_term(Formula, Symbol, Amount).

split_term(String, Symbol, Amount) :-
    nonvar(String) ->
        re_matchsub("(?<symbol>[A-z]*)(?<numstr>[0-9]*)?", String, Sub, []),
        get_dict(symbol, Sub, Symbol),
        get_dict(numstr, Sub, NumStr),
        NumStr \= "1",
        (number_string(Amount, NumStr) -> true; Amount is 1);
    nonvar(Symbol), nonvar(Amount) ->
        (
            Amount = 1 -> String = Symbol;
            string_concat(Symbol, Amount, String)
        ).


%!  homonulcear(+Formula) is semidet.
%!  homonulcear(-Formula) is failure.
%
homonuclear(Formula) :-
    get_all_elements(Formula, Elements),
    length(Elements,1).


%!  binary_compound_cn(+Formula: string, +Name: string) is semidet.
%!  binary_compound_cn(+Formula: string, -Name: string) is semidet.
%!  binary_compound_cn(-Formula: string, -Name: string) is failure.
%!  binary_compound_cn(-Formula: string, +Name: string) is semidet.
%
%   @arg Formula – the chemical formula of the binary compound
%   @arg Name – the stoichiometric name of the binary compound
%   
%   IR-5.2 p.81-82
%
binary_compound_cn(Formula, Name) :-
    nonvar(Name) ->
        binary_compound_name_atoms(Name, Atom),
        binary_compound_formula_atoms(Formula, Atom);
    binary_compound_formula_atoms(Formula, Atom),
    binary_compound_name_atoms(Name, Atom),
    % chcek formula
    binary_compound(Formula),
    not(ion(Formula)).


%!  binary_compound(+Formula:string) is semidet.
%!  binary_compound(-Formula:string) is failure.
%
binary_compound(Formula) :-
    get_all_elements(Formula, Elements),
    length(Elements, 2).


%!  binary_compound_formula_atoms(+Formula:string, +Atoms:list(Element:atom-Amount:int) is semidet.
%!  binary_compound_formula_atoms(+Formula:string, -Atoms:list(Element:atom-Amount:int) is semidet.
%!  binary_compound_formula_atoms(-Formula:string, +Atoms:list(Element:atom-Amount:int) is det.
%!  binary_compound_formula_atoms(-Formula:string, -Atoms:list(Element:atom-Amount:int) is failure.
%
%
%   Note: doesn't check if `Formula` is in the correct form.
%
binary_compound_formula_atoms(Formula, Atoms) :-
    nonvar(Formula) ->
        count_atoms(Formula, Atoms);
    nonvar(Atoms) ->
        length(Atoms, 2),
        maplist(homonuclear_formula_atom, Terms, Atoms),
        join("", Terms, Formula);
    fail.


%!  binary_compound_name_atoms(+Name:string, +Atoms:list(Element:atom-Amount:int) is semidet.
%!  binary_compound_name_atoms(+Name:string, -Atoms:list(Element:atom-Amount:int) is semidet.
%!  binary_compound_name_atoms(-Name:string, +Atoms:list(Element:atom-Amount:int) is det.
%!  binary_compound_name_atoms(-Name:string, -Atoms:list(Element:atom-Amount:int) is failure.
%
%   True when `Atoms` is the list of `Element-Amount` represented by `Name`.
%   False when `Name` is not a stoichiometric name of binary compound.
%
binary_compound_name_atoms(Name, Atoms) :-
    nonvar(Name) ->
        binary_compound_name_atoms_(Name, Atoms);
    nonvar(Atoms) ->
        binary_compound_atoms_name_(Atoms, Name);
    fail.

binary_compound_name_atoms_(Name, Atoms) :-
    split_positive_negative(Name, PositivePart, NegativePart),
    electropositive_name_atom(PositivePart, PosElement-PosAmount),
    binary_electronegative_name_atom(NegativePart, NegElement-NegAmount),
    Atoms = [PosElement-PosAmount, NegElement-NegAmount].

binary_compound_atoms_name_(Atoms, Name) :-
    Atoms = [PosElement-PosAmount, NegElement-NegAmount],
    electropositive_name_atom(PositivePart, PosElement-PosAmount),
    binary_electronegative_name_atom(NegativePart, NegElement-NegAmount),
    split_positive_negative(Name, PositivePart, NegativePart).


%!  split_positive_negative(-Name:string, +PositivePart:string, +NegativePart) is semidet.
split_positive_negative(Name, PositivePart, NegativePart) :-
    nonvar(PositivePart), nonvar(NegativePart),
    string_concat(PositivePart, " ", T),
    string_concat(T, NegativePart, Name),
    !.

%!  split_positive_negative(+Name:string, -PositivePart:string, -NegativePart) is semidet.
split_positive_negative(Name, PositivePart, NegativePart) :-
    nonvar(Name),
    re_matchsub("(?<positive>[a-z]+) (?<negative>[a-z]+)", Name, Sub, []),
    get_dict(positive, Sub, PositivePart),
    get_dict(negative, Sub, NegativePart).


%!  electropositive_name_atom(+Name:string, +Element:atom-Amount:int) is semidet.
%!  electropositive_name_atom(+Name:string, -Element:atom-Amount:int) is semidet.
%!  electropositive_name_atom(-Name:string, -Element:atom-Amount:int) is multi.
%!  electropositive_name_atom(-Name:string, +Element:atom-Amount:int) is det.
electropositive_name_atom(Name, Element-Amount) :-
    nonvar(Name) ->
        electropositive_name_atom_(Name, Element-Amount), !;
    nonvar(Element), nonvar(Amount) ->
        electropositive_name_atom_(Name, Element-Amount), !;
    electropositive_name_atom_(Name, Element-Amount).

electropositive_name_atom_(Name, Element-Amount) :-
    between(1, 9999, Amount),
    element_name(Element, ElementName),
    (
        Amount = 1 -> MulPrefix = "";
        multiplicative_prefix(Amount, MulPrefix)
    ),
    string_concat(MulPrefix, ElementName, Name).


%!  electronegative_name_atom(+Name:string, +Element:atom-Amount:int) is semidet.
%!  electronegative_name_atom(+Name:string, -Element:atom-Amount:int) is semidet.
%!  electronegative_name_atom(-Name:string, -Element:atom-Amount:int) is multi.
%!  electronegative_name_atom(-Name:string, +Element:atom-Amount:int) is det.
electronegative_name_atom(Name, Element-Amount) :-
    nonvar(Name) ->
        electronegative_name_atom_(Name, Element-Amount), !;
    nonvar(Element), nonvar(Amount) ->
        electronegative_name_atom_(Name, Element-Amount), !;
    electronegative_name_atom_(Name, Element-Amount).

electronegative_name_atom_(Name, Element-Amount) :-
    between(1, 9999, Amount),
    element_name(Element, ElementName),
    append_suffix(ElementName, "ide", IdeName),
    (
        Amount = 1 -> MulPrefix = "";
        multiplicative_prefix(Amount, MulPrefix)
    ),
    prepend_prefix(IdeName, MulPrefix, Name).


%!  binary_electronegative_name_atom(+Name:string, +Element:atom-Amount:int) is semidet.
%!  binary_electronegative_name_atom(+Name:string, -Element:atom-Amount:int) is semidet.
%!  binary_electronegative_name_atom(-Name:string, -Element:atom-Amount:int) is multi.
%!  binary_electronegative_name_atom(-Name:string, +Element:atom-Amount:int) is det.
binary_electronegative_name_atom(Name, Element-Amount) :-
    nonvar(Name) ->
        binary_electronegative_name_atom_loose_(Name, Element-Amount), !;
    nonvar(Element), nonvar(Amount) ->
        binary_electronegative_name_atom_(Name, Element-Amount), !;
    binary_electronegative_name_atom_(Name, Element-Amount).

binary_electronegative_name_atom_(Name, Element-Amount) :-
    between(1, 9999, Amount),
    element_name(Element, ElementName),
    append_suffix(ElementName, "ide", IdeName),
    (
        Amount = 1, Element \= oxygen -> MulPrefix = "";
        multiplicative_prefix(Amount, MulPrefix)
    ),
    prepend_prefix(IdeName, MulPrefix, Name).

binary_electronegative_name_atom_loose_(Name, Element-Amount) :-
    between(1, 9999, Amount),
    element_name(Element, ElementName),
    append_suffix(ElementName, "ide", IdeName),
    (
        Amount = 1, Element \= oxygen, MulPrefix = "";
        multiplicative_prefix(Amount, MulPrefix)
    ),
    prepend_prefix(IdeName, MulPrefix, Name).


%!  ion_cn(+Formula: string, +Name: string) is semidet.
%!  ion_cn(+Formula: string, -Name: string) is semidet.
%!  ion_cn(-Formula: string, +Name: string) is semidet.
%!  ion_cn(-Formula: string, -Name: string) is failure.
%
%   @arg Formula – the chemical formula of the cationic or anionic compound
%   @arg Name – the compositional name of the cationic or anionic compound
%
ion_cn(Formula, Name) :-
    cation_cn(Formula, Name) -> true;
    anion_cn(Formula, Name).


cation_cn(Formula, Name) :-
    monoatomic_cation_cn(Formula, Name) -> true;
    homopolyatomic_cation_cn(Formula, Name).


anion_cn(Formula, Name) :-
    monoatomic_anion_cn(Formula, Name) -> true;
    homopolyatomic_anion_cn(Formula, Name).


%!  monoatomic_cation_cn(+Formula: string, -Name: string) is multi.
%!  monoatomic_cation_cn(+Formula: string, +Name: string) is semidet.
%!  monoatomic_cation_cn(-Formula: string, +Name: string) is ERROR.
%
%   IR-5.3.2.2 p.82-83
%
monoatomic_cation_cn(Formula, Name) :-
    (
        nonvar(Name) ->
            homoatomic_ion_name_atom(Name, Element-1, Charge),
            homoatomic_ion_formula_atom(Formula, Element-1, Charge);
        nonvar(Formula) ->
            homoatomic_ion_formula_atom(Formula, Element-1, Charge),
            homoatomic_ion_name_atom(Name, Element-1, Charge)
    ),
    % chcek formula
    monoatomic(Formula),
    cation(Formula).
% monoatomic_cation_cn("[Na]+", "sodium(1+)")


%!  homopolyatomic_cation_cn(+Formula: string, -Name: string) is multi.
%!  homopolyatomic_cation_cn(+Formula: string, +Name: string) is nondet.
%!  homopolyatomic_cation_cn(-Formula: string, +Name: string) is failure.
%
%   IR-5.3.2.3 p.83
%   [O2]+ => dioxygen(1+)
%
homopolyatomic_cation_cn(Formula, Name) :-
    (
        nonvar(Name) ->
            homoatomic_ion_name_atom(Name, Element-Amount, Charge),
            Amount \= 1,
            homoatomic_ion_formula_atom(Formula, Element-Amount, Charge);
        nonvar(Formula) ->
            homoatomic_ion_formula_atom(Formula, Element-Amount, Charge),
            Amount \= 1,
            homoatomic_ion_name_atom(Name, Element-Amount, Charge)
    ),
    % chcek formula
    homopolyatomic(Formula),
    cation(Formula).


%!  monoatomic_anion_cn(+Formula: string, -Name: string) is multi.
%!  monoatomic_anion_cn(+Formula: string, +Name: string) is semidet.
%!  monoatomic_anion_cn(-Formula: string, +Name: string) is ERROR.
%
%   IR-5.3.3.2 p.84-85
%
monoatomic_anion_cn(Formula, Name) :-
    (
        nonvar(Name) ->
            homoatomic_ion_name_atom(Name, Element-1, Charge),
            homoatomic_ion_formula_atom(Formula, Element-1, Charge);
        nonvar(Formula) ->
            homoatomic_ion_formula_atom(Formula, Element-1, Charge),
            homoatomic_ion_name_atom(Name, Element-1, Charge)
    ),
    % chcek formula
    monoatomic(Formula),
    anion(Formula).


%!  homopolyatomic_anion_cn(+Formula: string, -Name: string) is multi.
%!  homopolyatomic_anion_cn(+Formula: string, +Name: string) is nondet.
%!  homopolyatomic_anion_cn(-Formula: string, +Name: string) is failure.
%
%   IR-5.3.3.3 p.85
%   [O2]2- => dioxide(2-)
%
homopolyatomic_anion_cn(Formula, Name) :-
    (
        nonvar(Name) ->
            homoatomic_ion_name_atom(Name, Element-Amount, Charge),
            Amount \= 1,
            homoatomic_ion_formula_atom(Formula, Element-Amount, Charge);
        nonvar(Formula) ->
            homoatomic_ion_formula_atom(Formula, Element-Amount, Charge),
            Amount \= 1,
            homoatomic_ion_name_atom(Name, Element-Amount, Charge)
    ),
    % chcek formula
    homopolyatomic(Formula),
    anion(Formula).


%!  homoatomic_ion_formula_atom(+Formula:string, +Element:atom-Amount:int, +Charge:int) is semidet.
%!  homoatomic_ion_formula_atom(+Formula:string, -Element:atom-Amount:int, -Charge:int) is semidet.
%!  homoatomic_ion_formula_atom(-Formula:string, -Element:atom-Amount:int, -Charge:int) is failure.
%!  homoatomic_ion_formula_atom(-Formula:string, +Element:atom-Amount:int, +Charge:int) is det.
%
homoatomic_ion_formula_atom(Formula, Element-Amount, Charge) :-
    nonvar(Formula) ->
        count_atoms(Formula, Atoms),
        Atoms = [Element-Amount],
        get_net_charge(Formula, Charge);
    nonvar(Element), nonvar(Amount), nonvar(Charge) ->
        homoatomic_ion_atom_formula_(Element-Amount, Charge, Formula);
    fail.

%   homoatomic_ion_atom_formula_(+Element-Amount, +Charge, -Formula) is det.
homoatomic_ion_atom_formula_(Element-Amount, Charge, Formula) :-
    homonuclear_formula_atom(Term, Element-Amount),
    (
        Charge = 1 ->
            ChargePart = "+";
        Charge = -1 ->
            ChargePart = "-";
        charge_string(ChargePart, Charge)
    ),
    join("", ["(", Term, ")", ChargePart], Formula).


%!  homoatomic_ion_name_atom(+Name:string, +Element:atom-Amount:int, +Charge:int) is semidet.
%!  homoatomic_ion_name_atom(+Name:string, -Element:atom-Amount:int, -Charge:int) is semidet.
%!  homoatomic_ion_name_atom(-Name:string, -Element:atom-Amount:int, -Charge:int) is failure.
%!  homoatomic_ion_name_atom(-Name:string, +Element:atom-Amount:int, +Charge:int) is det.
%
homoatomic_ion_name_atom(Name, Element-Amount, Charge) :-
    nonvar(Name) ->
        homoatomic_ion_name_atom_(Name, Element-Amount, Charge);
    nonvar(Element), nonvar(Amount), nonvar(Charge) ->
        homoatomic_ion_atom_name_(Element-Amount, Charge, Name), !.

homoatomic_ion_name_atom_(Name, Element-Amount, Charge) :-
    nonvar(Name),
    re_matchsub("(?<name_part>[a-z]+)\\((?<charge_part>[1-9][0-9]*[+-])\\)", Name, Sub, []),
    get_dict(name_part, Sub, NamePart),
    get_dict(charge_part, Sub, ChargePart),
    charge_string(ChargePart, Charge),
    (
        Charge > 0 ->
            electropositive_name_atom(NamePart, Element-Amount);
        Charge < 0 ->
            electronegative_name_atom(NamePart, Element-Amount)
    ).

homoatomic_ion_atom_name_(Element-Amount, Charge, Name) :-
    between(1, infinite, Amount),
    MaxCharge is 9 * Amount,        % +9, -5
    between(1, MaxCharge, Charge_),
    (
        Charge is Charge_ ->
            electropositive_name_atom(NamePart, Element-Amount);
        Charge is -Charge_ ->
            electronegative_name_atom(NamePart, Element-Amount)
    ),
    charge_string(ChargePart, Charge),
    join("", [NamePart, "(", ChargePart, ")"], Name).


charge_string(ChargePart, Charge) :-
    nonvar(Charge),
    AbsCharge is abs(Charge),
    number_string(AbsCharge, NumStr),
    (
        Charge > 0 ->
            string_concat(NumStr, "+", ChargePart);
        Charge < 0 ->
            string_concat(NumStr, "-", ChargePart)
    ), !.

charge_string(ChargePart, Charge) :-
    nonvar(ChargePart),
    re_matchsub("(?<num>[1-9][0-9]*)(?<sign>[+-])", ChargePart, Sub, []),
    get_dict(num, Sub, NumStr),
    get_dict('sign', Sub, Sign),
    (
        Sign = "+" ->
            number_string(Charge, NumStr);
        Sign = "-" ->
            number_string(Num_, NumStr),
            Charge is -Num_
    ).


%!  addition_compound_cn(+Formula:string, +Name:string) is semidet.
%!  addition_compound_cn(+Formula:string, -Name:string) is multi.
%!  addition_compound_cn(-Formula:string, +Name:string) is failure.
%!  addition_compound_cn(-Formula:string, -Name:string) is failure.
%
% # IR-5.5 p.92-93 ← IR-4
% # BF3⋅2H2O ⇒ boron triﬂuoride—water (1/2)
% # 8Kr⋅46H2O ⇒ krypton—water (8/46)
%
%   @arg Formula – the chemical formula of the addition compound
%   @arg Name – the compositional name of the addition compound
%
addition_compound_cn(Formula, Name) :-
    (
        nonvar(Formula), nonvar(Name) ->
            split_addition_compound(Formula, Compounds, Amounts),
            addition_compound_components_name(Compounds, Amounts, Name),
            !;
        nonvar(Formula) ->
            split_addition_compound(Formula, Compounds, Amounts),
            addition_compound_components_name(Compounds, Amounts, Name);
        nonvar(Name) ->
            addition_compound_components_name(Compounds, Amounts, Name),
            split_addition_compound(Formula, Compounds, Amounts);
        fail
    ),
    % check
    addition_compound(Formula). 

%
%
%
addition_compound(Formula) :-
    split_addition_compound(Formula, Compounds, _),
    length(Compounds, X),
    X > 1,
    !.

%
%
%
addition_compound_components_name(Compounds, Amounts, Name) :-
    nonvar(Compounds), nonvar(Amounts) ->
        addition_compound_components_name_(Compounds, Amounts, Name);
    nonvar(Name) ->
        addition_compound_name_components_(Name, Compounds, Amounts);
    fail.

addition_compound_components_name_(Compounds, Amounts, Name) :-
    join("/", Amounts, RatioPart),
    maplist(get_iupac_name_or_addition_compound_exception, Compounds, Names),
    join("\u2014", Names, NamePart),
    join("", [NamePart, " (", RatioPart, ")"], Name).

addition_compound_name_components_(Name, Compounds, Amounts) :-
    re_matchsub("^(?<compounds>.+) \\((?<ratio>.*)\\)$", Name, Sub, []),
    get_dict(compounds, Sub, CompoundsPart),
    get_dict(ratio, Sub, RatioPart),
    split_string(CompoundsPart, "\u2014", "", Names),
    split_string(RatioPart, "/", "", Amounts_),
    maplist(number_string, Amounts, Amounts_),
    maplist(get_iupac_name_or_addition_compound_exception, Compounds, Names).

get_iupac_name_or_addition_compound_exception(Formula, Name) :-
    nonvar(Name) ->
        get_iupac_name_or_addition_compound_exception_(Formula, Name),
        !;
    get_iupac_name_or_addition_compound_exception_(Formula, Name). 

get_iupac_name_or_addition_compound_exception_(Formula, Name) :-
    (
        alternative_name(Formula, Name);
        homonuclear_cn(Formula, Name);
        binary_compound_cn(Formula, Name);
        ion_cn(Formula, Name);
        general_stoichiometric_name(Formula, Name);
        boron_hydride_stoichiometric_name(Formula, Name);
        substitutive_name(Formula, Name);
        additive_name(Formula, Name)
    ).


%!  split_addition_compound_(+Formula:string, +Compounds:string, +Amounts:int) is semidet.
%!  split_addition_compound_(+Formula:string, -Compounds:string, -Amounts:int) is semidet.
%!  split_addition_compound_(-Formula:string, -Compounds:string, -Amounts:int) is failure.
%!  split_addition_compound_(-Formula:string, +Compounds:string, +Amounts:int) is semidet.
%
%
split_addition_compound(Formula, Compounds, Amounts) :-
    nonvar(Compounds), nonvar(Amounts) ->
        join_addition_compound_(Formula, Compounds, Amounts);
    nonvar(Formula) ->
        split_addition_compound_(Formula, Compounds, Amounts);
    fail.

%!  split_addition_compound_(+Formula:string, -Compounds:string, -Amounts:int) is semidet.
split_addition_compound_(Formula, Compounds, Amounts) :-
    split_string(Formula, "\u22C5", "", Components),
    maplist(re_matchsub("(?<amount>[1-9][0-9]*)?(?<compound>.*)"), Components, Matches_),
    maplist(dict_remove_on_cond(value_is_empty_string), Matches_, Matches),
    maplist(get_dict('compound'), Matches, Compounds),
    maplist(get_dict_or_default("1", 'amount'), Matches, AmountStrs),
    maplist(number_string, Amounts, AmountStrs).

%!  join_addition_compound_(-Formula:string, +Compounds:string, +Amounts:int) is semidet.
join_addition_compound_(Formula, Compounds, Amounts) :-
    maplist(get_component_, Compounds, Amounts, Components),
    join("\u22C5", Components, Formula).

get_component_(Compound, Amount, Component) :-
    (
        Amount = 1 -> AmountStr = "";
        number_string(Amount, AmountStr)
    ),
    string_concat(AmountStr, Compound, Component).

re_matchsub(Pattern, String, Sub) :- re_matchsub(Pattern, String, Sub, []).


%!  general_stoichiometric_name(+Formula: string, +Name: string) is semidet.
%!  general_stoichiometric_name(+Formula: string, -Name: string) is semidet.
%!  general_stoichiometric_name(-Formula: string, +Name: string) is failure.
%!  general_stoichiometric_name(-Formula: string, -Name: string) is failure.
%
%   @arg Formula – the generalized salt formula
%   @arg Name –  the stoichiometric name of the generalized salt formula
%
general_stoichiometric_name(Formula, Name) :-
    general_ion_stoichiometric_name(Formula, Name) -> true;
    general_neutral_stoichiometric_name(Formula, Name).

general_neutral_stoichiometric_name(Formula, Name) :-
    (
        nonvar(Name) -> (
            generalized_salt_name_atoms(Name, EPCs, ENCs),
            generalized_salt_formula_atoms(Formula, EPCs, ENCs)
        );
        nonvar(Formula) -> (
            generalized_salt_formula_atoms(Formula, EPCs, ENCs),
            generalized_salt_name_atoms(Name, EPCs, ENCs)
        )
    ),
    % check
    not(binary_compound(Formula)),
    not(ion(Formula)).

general_ion_stoichiometric_name(Formula, Name) :-
    nonvar(Name) -> (
        re_matchsub("^\\((?<name_part>.+)\\)\\((?<charge_part>[1-9][0-9]*[+-])\\)$", Name, Sub, []),
        get_dict(name_part, Sub, NeutralName),
        get_dict(charge_part, Sub, ChargePart_),
        (
            ChargePart_ = "1+" -> ChargePart = "+";
            ChargePart_ = "1-" -> ChargePart = "-";
            ChargePart = ChargePart_
        ),
        general_neutral_stoichiometric_name(NeutralFormula, NeutralName),
        join("", ["(", NeutralFormula, ")", ChargePart], Formula)
    );
    nonvar(Formula) -> (
        get_charge_str(Formula, ChargePart),
        get_neutral_specie(Formula, NeutralFormula),
        general_neutral_stoichiometric_name(NeutralFormula, NeutralName),
        join("", ["(", NeutralName, ")", ChargePart], Name)
    ).


%!  generalized_salt_name_atoms(+Name:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is semidet.
%!  generalized_salt_name_atoms(+Name:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is semidet.
%!  generalized_salt_name_atoms(-Name:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is failure.
%!  generalized_salt_name_atoms(-Name:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is det.
%
generalized_salt_name_atoms(Name, EPCs, ENCs) :-
    nonvar(EPCs), nonvar(ENCs) ->
        generalized_salt_atoms_name_(EPCs, ENCs, Name);
    nonvar(Name) ->
        generalized_salt_name_atoms_(Name, EPCs, ENCs);
    fail.

%!  generalized_salt_name_atoms_(+Name:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is semidet.
generalized_salt_name_atoms_(Name, EPCs, ENCs) :-
    split_string(Name, " ", "", SubStrings),
    append(EPCNames, ENCNames, SubStrings),
    EPCNames \= [], ENCNames \= [],
    maplist(electropositive_name_atom, EPCNames, EPCs),
    maplist(electronegative_name_atom, ENCNames, ENCs),
    !.

%!  generalized_salt_name_atoms_(+EPCs:list(Element-Amount), +ENCs:list(Element-Amount), -Name:string) is det.
generalized_salt_atoms_name_(EPCs, ENCs, Name) :-
    maplist(electropositive_name_atom, EPCNames, EPCs),
    maplist(electronegative_name_atom, ENCNames, ENCs),
    append(EPCNames, ENCNames, PCNames),
    join(" ", PCNames, Name).


%!  generalized_salt_formula_atoms(+Formula:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is semidet.
%!  generalized_salt_formula_atoms(+Formula:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is multi.
%!  generalized_salt_formula_atoms(-Formula:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is failure.
%!  generalized_salt_formula_atoms(-Formula:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is det.
%
generalized_salt_formula_atoms(Formula, EPCs, ENCs) :-
    nonvar(EPCs), nonvar(ENCs) ->
        generalized_salt_atoms_formula_(EPCs, ENCs, Formula);
    nonvar(Formula) ->
        generalized_salt_formula_atoms_(Formula, EPCs, ENCs);
    fail.

%!  generalized_salt_formula_atoms_(+Formula:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is semidet.
%!  generalized_salt_formula_atoms_(+Formula:string, -EPCs:list(Element-Amount), -ENCs:list(Element-Amount)) is multi.
generalized_salt_formula_atoms_(Formula, EPCs, ENCs) :-
    count_atoms(Formula, Atoms),
    append(EPCs_, ENCs_, Atoms),
    EPCs_ \= [], ENCs_ \= [],
    (
        selectchk(hydrogen-_, EPCs_, EPCRest) ->
            sort(0, @=<, EPCRest, EPCRest),
            append(EPCRest, [hydrogen-_], EPCs);
            sort(0, @=<, EPCs_, EPCs_)
    ),
    sort(0, @=<, ENCs_, ENCs_),
    EPCs = EPCs_,
    ENCs = ENCs_.

%!  generalized_salt_atoms_formula_(-Formula:string, +EPCs:list(Element-Amount), +ENCs:list(Element-Amount)) is det.
generalized_salt_atoms_formula_(EPCs, ENCs, Formula) :-
    append(EPCs, ENCs, Constituents),
    maplist(homonuclear_formula_atom, Terms, Constituents),
    join("", Terms, Formula).
 

%!  boron_hydride_stoichiometric_name(+Formula:string, +Name:string) is semidet.
%!  boron_hydride_stoichiometric_name(+Formula:string, -Name:string) is semidet.
%!  boron_hydride_stoichiometric_name(-Formula:string, -Name:string) is failure.
%!  boron_hydride_stoichiometric_name(-Formula:string, +Name:string) is semidet.
%
%   IR-6.2.3.1
%   @arg Formula – the borin hydride formula
%   @arg Name –  the stoichiometric name of the boron hydride formula
%
boron_hydride_stoichiometric_name(Formula, Name) :-
    (
        nonvar(Formula) ->
            boron_hydride_stoichiometric_formula_atoms(Formula, Atoms),
            boron_hydride_stoichiometric_name_atoms(Name, Atoms);
        nonvar(Name) ->
            boron_hydride_stoichiometric_name_atoms(Name, Atoms),
            boron_hydride_stoichiometric_formula_atoms(Formula, Atoms);
        fail
    ),
    % check
    boron_hydride(Formula).


boron_hydride(Formula) :-
    get_all_elements(Formula,Elements),
    Elements = [boron, hydrogen].


%!  boron_hydride_stoichiometric_name_atoms(+Name:string, +Atoms:list(Element:atom-Amount:int)) is semidet.
%!  boron_hydride_stoichiometric_name_atoms(+Name:string, -Atoms:list(Element:atom-Amount:int)) is semidet.
%!  boron_hydride_stoichiometric_name_atoms(-Name:string, -Atoms:list(Element:atom-Amount:int)) is failure.
%!  boron_hydride_stoichiometric_name_atoms(-Name:string, +Atoms:list(Element:atom-Amount:int)) is semidet.
%
%   Reference: https://en.wikipedia.org/wiki/Borane
%
boron_hydride_stoichiometric_name_atoms(Name, Atoms) :-
    nonvar(Atoms) ->
        Atoms = [boron-NumBoron, hydrogen-NumHydrogen],
        (
            NumBoron = 1 -> MulPrefix = "";
            multiplicative_prefix(NumBoron, MulPrefix)
        ),(
            NumBoron = 1, NumHydrogen = 3 ->
                HydrogenPart = "";
            join("", ["(", NumHydrogen, ")"], HydrogenPart)
        ),
        join("", [MulPrefix, "borane", HydrogenPart], Name);
    nonvar(Name) ->
        re_matchsub("(?<prefix>[a-z]*)?borane(\\((?<num>[1-9][0-9]*)\\))?", Name, Sub, []),
        get_dict(prefix, Sub, MulPrefix),
        (
            MulPrefix = "" -> NumBoron = 1;
            multiplicative_prefix(NumBoron, MulPrefix)
        ),
        (
            get_dict(num, Sub, NumHydrogenStr) ->
                number_string(NumHydrogen, NumHydrogenStr);
            NumBoron = 1, NumHydrogen = 3
        ),
        Atoms = [boron-NumBoron, hydrogen-NumHydrogen];
    fail.


%!  boron_hydride_stoichiometric_formula_atoms(+Formula:string, +Atoms:list(Element:atom-Amount:int)) is semidet.
%!  boron_hydride_stoichiometric_formula_atoms(+Formula:string, -Atoms:list(Element:atom-Amount:int)) is semidet.
%!  boron_hydride_stoichiometric_formula_atoms(-Formula:string, -Atoms:list(Element:atom-Amount:int)) is failure.
%!  boron_hydride_stoichiometric_formula_atoms(-Formula:string, +Atoms:list(Element:atom-Amount:int)) is semidet.
%
boron_hydride_stoichiometric_formula_atoms(Formula, Atoms) :-
    nonvar(Formula) ->
        count_atoms(Formula, Atoms),
        Atoms = [boron-_NumBoron, hydrogen-_NumHydrogen];
    nonvar(Atoms) ->
        Atoms = [boron-_NumBoron, hydrogen-_NumHydrogen],
        maplist(homonuclear_formula_atom, Terms, Atoms),
        join("",Terms, Formula);
    fail.
