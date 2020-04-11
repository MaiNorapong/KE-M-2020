:- module(inorganic,[additive_name/2,substitutive_name/2,compositional_name/2,inorganic_name/2]).

:- use_module(icompositional,[boron_hydride_stoichiometric_name/2,general_stoichiometric_name/2,addition_compound_cn/2,ion_cn/2,binary_compound_cn/2,homonuclear_cn/2]).
:- use_module(isubstitutive,[boron_hydride_structural_descriptor_name/2,parent_hydride_ion_sn/2,parent_hydride_sn/2]).
:- use_module(iadditive,[polynulcear_entity_an/2,mononuclear_entity_an/2]).
:- use_module(ialternative,[alternative_name/2]).


inorganic_name(Formula, Name) :-
    compositional_name(Formula, Name);
    substitutive_name(Formula, Name);
    additive_name(Formula, Name);
    alternative_name(Formula, Name).


%!  compositional_name(+Formula: string, +Name: string) is semidet.
%!  compositional_name(+Formula: string, -Name: string) is semidet.
%!  compositional_name(-Formula: string, +Name: string) is semidet.
%!  compositional_name(-Formula: string, -Name: string) is failure.
%
%   @arg Formula – the chemical formula of an element or a compound
%        Name – the compositional name of an element or a compound
%
compositional_name(Formula, Name) :-
    (
        homonuclear_cn(Formula, Name) -> true;
        binary_compound_cn(Formula, Name) -> true;
        ion_cn(Formula, Name) -> true;
        general_stoichiometric_name(Formula, Name) -> true;
        addition_compound_cn(Formula, Name)
    ).


% stoichiometric_name(Formula, Name) :-
%     nonvar(Name) -> stoichiometric_name_(Formula, Name), !;
%     stoichiometric_name_(Formula, Name).

% stoichiometric_name_(Formula, Name) :-
%     boron_hydride_stoichiometric_name(Formula, Name);
%     general_stoichiometric_name(Formula, Name).


substitutive_name(Formula, Name) :-
    (
        parent_hydride_sn(Formula, Name) -> true;
        parent_hydride_ion_sn(Formula, Name) -> true;
        boron_hydride_sn(Formula, Name)
    ).

boron_hydride_sn(Formula, Name) :-
    boron_hydride_structural_descriptor_name(Formula, Name);
    boron_hydride_stoichiometric_name(Formula, Name).


additive_name(Formula, Name) :-
    mononuclear_entity_an(Formula, Name);
    polynulcear_entity_an(Formula, Name).
