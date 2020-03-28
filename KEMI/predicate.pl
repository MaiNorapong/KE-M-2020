:- use_module(elements, [group/2, element_name/2]).
:- use_module(facts, [alternative_element_name_fact/2]).


%! append_suffix(+Element: atom, +Suffix: string, -Result: string) is det.
%! append_suffix(+Element: atom, +Suffix: string, +Result: string) is semidet.
%
%  Append `Suffix` to the name of `Element`
%
append_suffix(Element, Suffix, Result) :-
    (
        Suffix = "ide" -> idify(Element, Result);
        Suffix = "ane" -> anify(Element, Result);
        Suffix = "yl" -> ylify(Element, Result);
        Suffix = "ylidene" -> ylidenify(Element, Result);
        Suffix = "ylidyne" -> ylidynify(Element, Result)
    ).


idify_(ElementName, [], Result) :-
    % ElemntName doesn't match any suffix in SuffixList
    Result = ElementName,
    !.
idify_(ElementName, SuffixList, Result) :-
    SuffixList = [ESuffixH|ESuffixT],
    (
        string_concat(Root, ESuffixH, ElementName) -> Result = Root, !;
        idify_(ElementName, ESuffixT, Result)
    ).
%! idify(+Element: atom, -Result: string) is det.
%! idify(+Element: atom, +Result: string) is semidet.
%
%  Add suffix -ide to the name of `Element`
%  TODO: (-Element, +Result)
idify(Element, Result) :-
    % Add -ide to the end of Group 18 which ends with -on
    group(Element, 18),
    element_name(Element, Name),
    string_concat(_, "on", Name),
    string_concat(Name, "ide", Result),
    !.
idify(Element, Result) :-
    element_name(Element, Name),
    not(group(Element, 18)),
    SuffixList = [
        "ogen", "orus", "ygen", "ese", "ine", "ium", "en",
        "ic", "on", "um", "ur", "y"
    ],
    idify_(Name, SuffixList, Name_),
    string_concat(Name_, "ide", Result),
    !.


anify_(ElementName, [], Result) :-
    % ElemntName doesn't match any suffix in SuffixList
    Result = ElementName,
    !.
anify_(ElementName, SuffixList, Result) :-
    SuffixList = [ESuffixH|ESuffixT],
    (
        string_concat(Root, ESuffixH, ElementName) -> Result = Root, !;
        anify_(ElementName, ESuffixT, Result)
    ).
%! anify(+Element: atom, -Result: string) is det.
%! anify(+Element: atom, +Result: string) is semidet.
%
%  Add suffix -ane to the name of `Element`
%  TODO: (-Element, +Result)
anify(Element, Result) :-
    (
        alternative_element_name_fact(Element, Name_) -> Name = Name_;
        not(alternative_element_name_fact(Element, _)),
        element_name(Element, Name)
    ),
    SuffixList = [
        "inium", "onium", "urium", "aium", "eium", "enic",
        "icon", "inum", "ogen", "orus", "gen", "ine", "ium",
        "on", "um", "ur"
    ],
    anify_(Name, SuffixList, Root_),
    (
        string_concat(TempStr, "e", Root_) ->
            string_concat(TempStr, "i", Root);
        Root = Root_
    ),
    string_concat(Root, "ane", Result).


ylify(Element, Result) :-
    false.
    % element_name(Element, Name),
    % (
    %     string_concat(NameElideE, "e", Name) -> Name_ = NameElideE;
    %     Name_ = Name
    % ),
    % string_concat(Name_, "yl", Result).


ylidenify(Element, Result) :-
    false.


ylidynify(Element, Result) :-
    false.