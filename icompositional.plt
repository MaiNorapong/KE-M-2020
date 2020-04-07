:- begin_tests(icompositional).
:- use_module(icompositional, [
    binary_compound_cn/2, 
    binary_compound_name_atoms/2, 
    monoatomic_cation_cn/2,
    homonuclear_name_atom/2,
    homonuclear_cn/2,
    homopolyatomic_cation_cn/2,
    homopolyatomic_anion_cn/2,
    monoatomic_anion_cn/2,
    general_stoichiometric_name/2,
    general_neutral_stoichiometric_name/2,
    boron_hydride_stoichiometric_name/2,
    addition_compound_cn/2
    ]).

test(homonuclear_cn) :-
    %test + -
    homonuclear_name_atom("mononitrogen",C0),
    assertion(C0 == nitrogen-1),

    homonuclear_cn("N",C1),
    assertion(C1 == "mononitrogen"),
    homonuclear_cn("Ar",C2),
    assertion(C2 == "argon"),
  
    %test - +
    homonuclear_cn(D1, tetraphosphorus),
    assertion(D1 == "P4"),
    homonuclear_cn(D2, hexasulfur),
    assertion(D2 == "S6"),
 
    %test + +
    assertion(homonuclear_name_atom("monohydrogen", hydrogen-1)),
    assertion(homonuclear_name_atom("dioxygen", oxygen-2)),
 
    assertion(homonuclear_cn("C60", hexacontacarbon)),
    assertion(homonuclear_cn("S8", octasulfur)),

    % test fail cases
    assertion(not(homonuclear_cn("NaCl", _))),
    assertion(not(homonuclear_cn("Na+", _))),
    assertion(not(homonuclear_cn("I-", _))),
    assertion(not(homonuclear_cn("PBrClI", _))),
  
    true.
 
test(binary_compound_cn) :-
    %test + -
    binary_compound_name_atoms("hydrogen chloride",A0),
    assertion(A0 == [hydrogen-1, chlorine-1]),
    binary_compound_name_atoms("nitrogen monooxide",A1),
    binary_compound_name_atoms("nitrogen monoxide",A1),
    assertion(A1 == [nitrogen-1, oxygen-1]),
    binary_compound_name_atoms("nitrogen dioxide",A2),
    assertion(A2 == [nitrogen-1, oxygen-2]),
    binary_compound_name_atoms("nickel stannide",A6),
    assertion(A6 == [nickel-1, tin-1]),
  
    %test - +
    binary_compound_name_atoms(B0, [hydrogen-1, chlorine-1]),
    assertion(B0 == "hydrogen chloride"),
    binary_compound_name_atoms(B1, [nitrogen-1, oxygen-1]),
    assertion(B1 == "nitrogen monoxide"),
    binary_compound_name_atoms(B2, [nitrogen-1, oxygen-2]),
    assertion(B2 == "nitrogen dioxide"),
    binary_compound_name_atoms(B3, [oxygen-2, chlorine-1]),
    assertion(B3 == "dioxygen chloride"),
    binary_compound_name_atoms(B6, [nickel-1, tin-1]),
    assertion(B6 == "nickel stannide"),
 
    %test + +
    assertion(binary_compound_name_atoms("hydrogen chloride", [hydrogen-1, chlorine-1])),
    assertion(binary_compound_name_atoms("nitrogen monoxide", [nitrogen-1, oxygen-1])),
    assertion(binary_compound_name_atoms("dioxygen chloride", [oxygen-2, chlorine-1])),
    assertion(binary_compound_name_atoms("nickel stannide", [nickel-1, tin-1])),

    % Red book IR-5.2 tests
    assertion(binary_compound_cn("NaCl", "sodium chloride")),
    assertion(binary_compound_cn("HCl", "hydrogen chloride")),
    assertion(binary_compound_cn("NO", "nitrogen monoxide")),
    assertion(binary_compound_cn("NO2", "nitrogen dioxide")),
    assertion(binary_compound_cn("N2O4", "dinitrogen tetraoxide")),
    assertion(binary_compound_cn("OCl2", "oxygen dichloride")),
    assertion(binary_compound_cn("O2Cl", "dioxygen chloride")),
    assertion(binary_compound_cn("Cr23C6", "tricosachromium hexacarbide")),

    % test fail case
    assertion(not(binary_compound_cn("Na", _))),
    assertion(not(binary_compound_cn("PBrClI", _))),
    assertion(not(binary_compound_cn("H+", _))),
    assertion(not(binary_compound_cn("(O2)2-", _))),

    true.

test(monoatomic_cation_cn) :-
    % test + -
    monoatomic_cation_cn("Na+", N0),
    assertion(N0 == "sodium(1+)"),
    monoatomic_cation_cn("(Cr)3+", N1),
    assertion(N1 == "chromium(3+)"),
    monoatomic_cation_cn("(I)+", N2),
    assertion(N2 == "iodine(1+)"),
    
    % test - +
    monoatomic_cation_cn(F0, "sodium(1+)"),
    assertion(F0 == "(Na)+"),
    monoatomic_cation_cn(F1, "chromium(3+)"),
    assertion(F1 == "(Cr)3+"),
    monoatomic_cation_cn(F2, "iodine(1+)"),
    assertion(F2 == "(I)+"),

    % test + +
    assertion(monoatomic_cation_cn("Na+", "sodium(1+)")),
    assertion(monoatomic_cation_cn("(Cr)3+", "chromium(3+)")),
    assertion(monoatomic_cation_cn("(I)+", "iodine(1+)")),

    % test fail case
    assertion(not(monoatomic_cation_cn("Cl-", _))),
    assertion(not(monoatomic_cation_cn("(Hg2)2+", _))),
    assertion(not(monoatomic_cation_cn("NaCl", _))),
    true.

test(homopolyatomic_cation_cn) :-
    % test + -
    homopolyatomic_cation_cn("(S4)2+", N0),
    assertion(N0 == "tetrasulfur(2+)"),
    homopolyatomic_cation_cn("(O2)+", N1),
    assertion(N1 == "dioxygen(1+)"),
    homopolyatomic_cation_cn("(Bi5)4+", N2),
    assertion(N2 == "pentabismuth(4+)"),

    % test - +
    homopolyatomic_cation_cn(F0, "tetrasulfur(2+)"),
    assertion(F0 == "(S4)2+"),
    homopolyatomic_cation_cn(F1, "dioxygen(1+)"),
    assertion(F1 == "(O2)+"),
    homopolyatomic_cation_cn(F2, "pentabismuth(4+)"),
    assertion(F2 == "(Bi5)4+"),
    
    % test + +
    assertion(homopolyatomic_cation_cn("(S4)2+", "tetrasulfur(2+)")),
    assertion(homopolyatomic_cation_cn("(O2)+", "dioxygen(1+)")),
    assertion(homopolyatomic_cation_cn("(Bi5)4+", "pentabismuth(4+)")),
    
    % test fail case
    assertion(not(homopolyatomic_cation_cn("Cl-", _))),
    assertion(not(homopolyatomic_cation_cn("Na+", _))),
    assertion(not(homopolyatomic_cation_cn("NaCl", _))),

    true.

test(monoatomic_anion_cn) :-
    % test + -
    monoatomic_anion_cn("(Cl)-",E0),
    assertion(E0 == "chloride(1-)"),
    monoatomic_anion_cn("(O)2-",E1),
    assertion(E1 == "oxide(2-)"),
    monoatomic_anion_cn("(N)3-",E2),
    assertion(E2 == "nitride(3-)"),
    
    % test - +
    monoatomic_anion_cn(G0, "chloride(1-)"),
    assertion(G0 == "(Cl)-"),
    monoatomic_anion_cn(G1, "oxide(2-)"),
    assertion(G1 == "(O)2-"),
    monoatomic_anion_cn(G2, "nitride(3-)"),
    assertion(G2 == "(N)3-"),
 
    % test + +
    assertion(monoatomic_anion_cn("(Cl)-", "chloride(1-)")),
    assertion(monoatomic_anion_cn("(O)2-", "oxide(2-)")),
    assertion(monoatomic_anion_cn("(N)3-", "nitride(3-)")),

    % test fail case
    assertion(not(monoatomic_anion_cn("Na+", _))),
    assertion(not(monoatomic_anion_cn("(O2)2-", _))),
    assertion(not(monoatomic_anion_cn("NaCl", _))),
    
    true.

test(homopolyatomic_anion_cn) :-
    % test + -
    homopolyatomic_anion_cn("(O2)2-", N0),
    assertion(N0 == "dioxide(2-)"),
    homopolyatomic_anion_cn("(I3)-", N1),
    assertion(N1 == "triiodide(1-)"),
    homopolyatomic_anion_cn("(Pb9)4-", N2),
    assertion(N2 == "nonaplumbide(4-)"),

    % test - +
    homopolyatomic_anion_cn(F0, "dioxide(2-)"),
    assertion(F0 == "(O2)2-"),
    homopolyatomic_anion_cn(F1, "triiodide(1-)"),
    assertion(F1 == "(I3)-"),
    homopolyatomic_anion_cn(F2, "nonaplumbide(4-)"),
    assertion(F2 == "(Pb9)4-"),
    
    % test + +
    assertion(homopolyatomic_anion_cn("(O2)2-", "dioxide(2-)")),
    assertion(homopolyatomic_anion_cn("(I3)-", "triiodide(1-)")),
    assertion(homopolyatomic_anion_cn("(Pb9)4-", "nonaplumbide(4-)")),

    % test fail case
    assertion(not(homopolyatomic_anion_cn("Na+", _))),
    assertion(not(homopolyatomic_anion_cn("I-", _))),
    assertion(not(homopolyatomic_anion_cn("NaCl", _))),
    
    true.

test(general_neutral_stoichiometric_name) :-
    % test + -
    general_neutral_stoichiometric_name("PBrClI", N0),
    assertion(N0 == "phosphorus bromide chloride iodide"),
    general_neutral_stoichiometric_name("CuK5Sb2", N1),
    assertion(N1 == "copper pentapotassium diantimonide"),
    general_neutral_stoichiometric_name("IBr", N2),
    assertion(N2 == "iodine bromide"),

    % test - +
    general_neutral_stoichiometric_name(F0, "phosphorus bromide chloride iodide"),
    assertion(F0 == "PBrClI"),
    general_neutral_stoichiometric_name(F1, "copper pentapotassium diantimonide"),
    assertion(F1 == "CuK5Sb2"),
    general_neutral_stoichiometric_name(F2, "iodine bromide"),
    assertion(F2 == "IBr"),

    % % test + +
    assertion(general_neutral_stoichiometric_name("PBrClI", "phosphorus bromide chloride iodide")),
    assertion(general_neutral_stoichiometric_name("CuK5Sb2", "copper pentapotassium diantimonide")),
    assertion(general_neutral_stoichiometric_name("IBr", "iodine bromide")),

    % % test fail case
    assertion(not(general_neutral_stoichiometric_name("(O2Cl2)+", _))),
    true.

test(boron_hydride_stoichiometric_name) :-
    % test + -
    boron_hydride_stoichiometric_name("B2H6", G0),
    assertion(G0 == "diborane(6)"),
    boron_hydride_stoichiometric_name("B20H16", G1),
    assertion(G1 == "icosaborane(16)"),
    boron_hydride_stoichiometric_name("BH3", G2),
    assertion(G2 == "borane"),
 
    % test - +
    boron_hydride_stoichiometric_name(H0, "diborane(6)"),
    assertion(H0 == "B2H6"),
    boron_hydride_stoichiometric_name(H1, "icosaborane(16)"),
    assertion(H1 == "B20H16"),
    boron_hydride_stoichiometric_name(H2, "borane"),
    assertion(H2 == "BH3"),
 
    % % test + +
    assertion(boron_hydride_stoichiometric_name("B2H6", "diborane(6)")),
    assertion(boron_hydride_stoichiometric_name("B20H16", "icosaborane(16)")),
    assertion(boron_hydride_stoichiometric_name("BH3", "borane")),
    
    % % test fail case
    assertion(not(boron_hydride_stoichiometric_name("BHe", _))),
    true.

test(addition_compound_cn) :-
    % \u22C5 = ·
    % \u2014 = —
    % test + -
    addition_compound_cn("8Kr\u22C546H2O", I0),
    assertion(I0 == "krypton\u2014water (8/46)"),
    % addition_compound_cn("2Na2CO3\u22C53H2O2", I1),
    % assertion(I1 == "sodium carbonate\u2014hydrogen peroxide (2/3)"),
    % addition_compound_cn("Na2SO4\u22C510H2O", I2),
    % assertion(I2 == "sodium sulfate\u2014water (1/10)"),
    % addition_compound_cn("CaCl2\u22C58NH3", I3),
    % assertion(I3 == "calcium chloride\u2014ammonia(1/8)"),
    addition_compound_cn("BF3\u22C52H2O", I4),
    assertion(I4 == "boron trifluoride\u2014water (1/2)"),
 
    % test - +
    % addition_compound_cn(J0, "cadmium sulfate—water (3/8)"),
    % assertion(J0 == "3CdSO4⋅8H2O"),
    addition_compound_cn(J1, "krypton\u2014water (8/46)"),
    assertion(J1 == "8Kr\u22C546H2O"),
    % addition_compound_cn(J2, "sodium sulfate—water (1/10)"),
    % assertion(J2 == "Na2SO4·10H2O"),
    addition_compound_cn(J3, "boron trifluoride\u2014water (1/2)"),
    assertion(J3 == "BF3\u22C52H2O"),
 
    % % % test + + 
    assertion(addition_compound_cn("8Kr\u22C546H2O", "krypton\u2014water (8/46)")),
    assertion(addition_compound_cn("BF3\u22C52H2O", "boron trifluoride\u2014water (1/2)")),
    % assertion(addition_compound_cn("3CdSO4\u22C58H2O", "cadmium sulfate\u2014water (3/8)")),
    % assertion(addition_compound_cn("Na2SO4\u22C510H2O", "sodium sulfate\u2014water (1/10)")),
    
    % test fail case
    assertion(not(addition_compound_cn("BF3-2H2O, _))),
    assertion(not(addition_compound_cn(_, "boron trifluoridewater (1/2)"))),
    true.


:- end_tests(icompositional).
