% include the knowledge base
:- ['load.pro'].

% to get sum of every element in a list
list_sum([], 0).
list_sum([Head|Tail], Total) :-
	list_sum(Tail, Rest),
	Total is Head+Rest.

% to get the length of a list
length_of([], 0).
length_of(List, Length) :-
	[_|Tail] = List,
	length_of(Tail, TailLength),
	Length is TailLength+1.

% multiply to lists' elements with each other in order
weighted_mul([], [], []).
weighted_mul([H1|T1], [H2|T2], [Head|TailResult]) :-
	weighted_mul(T1, T2, TailResult),
	(H1 > 0 -> Head is H1*H2; Head is 0).

% concatenate two lists
concatenate([], List, List).
concatenate([H1|T1], List2, [H1|TailResult]) :-
	concatenate(T1, List2, TailResult).

% append an element to the beginning of a list
pushFront(Item, List, [Item|List]).

% between predicate for floats
bet(L, R, B) :-
	Factor1 is B-L,
	Factor2 is R-B,
	Factor1 > 0,
	Factor2 > 0.

% adjusts limits list of a glanian
adjust_limits([], []).
adjust_limits([H1|T1], [H2|T2]) :-
	(H1 = [] -> H2 = [0, 1]; H2 = H1),
	adjust_limits(T1, T2).

% compares the limits with features
comp_lims([], []).
comp_lims([H1|T1], [H2|T2]) :-
	[Left|Tail] = H1,
	[Right|_] = Tail,
	bet(Left, Right, H2) -> comp_lims(T1, T2); fail.

% checks if the activity and city pairs are sufficient for the 3.9 case
is_compitable(Name, Activity, City) :-
	likes(Name, _, _),
	dislikes(Name, DislikedActs, _, _),
	city(City, _, ActivityList),
	find_possible_cities(Name, PossibleCities),
	(member(City, PossibleCities), member(Activity, ActivityList), not(member(Activity, DislikedActs)));
	likes(Name, LikedActs, _),
	dislikes(Name, _, DislikedCities, _),
	city(City, _, ActivityList),
	(not(member(City, DislikedCities)), member(Activity, ActivityList), member(Activity, LikedActs)).

% takes first N elements of a list
take(N, _, Xs) :- N =< 0, !, N =:= 0, Xs = [].
take(_, [], []).
take(N, [X|Xs], [X|Ys]) :- M is N-1, take(M, Xs, Ys).

% writes every single elemnt of list
loop_through_list(_File, []) :- !.
loop_through_list(File, [Head|Tail]) :-
	_-T-N = Head,
    write(File, T),
    write(File, ' - '),
    write(File, N),
    write('\n'),
    loop_through_list(File, Tail).
% does the file operation
write_list_to_file(Filename,List) :-
    open(Filename, write, File),
    loop_through_list(File, List),
    close(File).

% finds the distance for every feature
distance_evaluator([], [], []).
distance_evaluator([H1|T1], [H2|T2], [Head|TailResult]) :-
	distance_evaluator(T1, T2, TailResult),
	(H1 > 0 -> Head is (H1-H2)*(H1-H2); Head is 0).

% 3.1 glanian_distance(Name1, Name2, Distance) 5 points
glanian_distance(Name1, Name2, Distance) :-
	expects(Name1, _, Expects1),
	glanian(Name2, _, Features2),
	distance_evaluator(Expects1, Features2, Distances),
	list_sum(Distances, Factor),
	Distance is sqrt(Factor).

% 3.2 weighted_glanian_distance(Name1, Name2, Distance) 10 points
weighted_glanian_distance(Name1, Name2, Distance) :-
	expects(Name1, _, Expects1),
	glanian(Name2, _, Features2),
	weight(Name1, Weights),
	distance_evaluator(Expects1, Features2, Distances),
	weighted_mul(Weights, Distances, Res),
	list_sum(Res, Factor),
	Distance is sqrt(Factor).


% 3.3 find_possible_cities(Name, CityList) 5 points
find_possible_cities(Name, CityList) :-
	city(CityName, Habitants, _),
	member(Name, Habitants), !,
	likes(Name, _, LikedCities),
	pushFront(CityName, LikedCities, CityList).


% 3.4 merge_possible_cities(Name1, Name2, MergedCities) 5 points
merge_possible_cities(Name1, Name2, MergedCities) :-
	find_possible_cities(Name1, C1),
	find_possible_cities(Name2, C2),
	(Name1 == Name2 -> MergedCities = C1; concatenate(C1, C2, MergedCities)).

% 3.5 find_mutual_activities(Name1, Name2, MutualActivities) 5 points
find_mutual_activities(Name1, Name2, MutualActivities) :-
	likes(Name1, A1, _),
	likes(Name2, A2, _),
	intersection(A1, A2, MutualActivities).

% 3.6 find_possible_targets(Name, Distances, TargetList) 10 points
find_possible_targets(Name, Distances, TargetList) :-
	expects(Name, Genders, _),
	Genders = [] -> Distances = [], TargetList = [];
	findall(X, (expects(Name, G, _), glanian(X, Gender, _), member(Gender, G)), Res),
	setof(X-A, (member(A, Res), glanian_distance(Name, A, X)), Fin),
	sort(1, @<, Fin, Sorted),
	findall(X, member(X-A, Sorted), Distances),
	findall(A, member(X-A, Sorted), TargetList).

% 3.7 find_weighted_targets(Name, Distances, TargetList) 15 points
find_weighted_targets(Name, Distances, TargetList) :-
	expects(Name, Genders, _),
	Genders = [] -> Distances = [], TargetList = [];
	findall(X, (expects(Name, G, _), glanian(X, Gender, _), member(Gender, G)), Res),
	setof(X-A, (member(A, Res), weighted_glanian_distance(Name, A, X)), Fin),
	sort(1, @<, Fin, Sorted),
	findall(X, member(X-A, Sorted), Distances),
	findall(A, member(X-A, Sorted), TargetList).

% 3.8 find_my_best_target(Name, Distances, Activities, Cities, Targets) 20 points
find_my_best_target(Name, Distances, Activities, Cities, Targets) :-
	% to find targets
	dislikes(Name, DActs, DCities, Limits),
	adjust_limits(Limits, Adj),
	find_weighted_targets(Name, _, TList),
	findall(B, (member(B, TList), glanian(B, _, Feats), comp_lims(Adj, Feats), not(old_relation([Name, B])), (likes(B, Acts, _), intersection(DActs, Acts, Intr), length_of(Intr, X), X<3)), BetaTargets),
	% to find cities
	find_possible_cities(Name, Cities1),
	likes(Name, LActs, _),
	findall(C, (city(C, _, CActs), intersection(LActs, CActs, Its), length_of(Its, Y), Y>0), ActCities),
	concatenate(Cities1, ActCities, CitiesU),
	sort(CitiesU, CitiesS),
	findall(C, (member(C, CitiesS), not(member(C, DCities)), member(T, BetaTargets), merge_possible_cities(Name, T, Cs), member(C, Cs)), CitiesUnsorted),
	sort(CitiesUnsorted, BetaCities),
	% to find activitiy and city pairs
	findall(A-C, (member(C, BetaCities), city(C, _, CityActs), member(A, CityActs), not(member(A, DActs))), BetaUnsorted),
	sort(1, @=<, BetaUnsorted, BetaSorted),
	% to find every combination
	findall(D-A-C-T, (member(A-C, BetaSorted), member(T, BetaTargets), weighted_glanian_distance(Name, T, D)), AlphaUnsorted),
	sort(1, @=<, AlphaUnsorted, AlphaSorted),
	% split the AlphaSorted list that stores every combination into four lists
	findall(D, member(D-A-C-T, AlphaSorted), Distances),
	findall(A, member(D-A-C-T, AlphaSorted), Activities),
	findall(C, member(D-A-C-T, AlphaSorted), Cities),
	findall(T, member(D-A-C-T, AlphaSorted), Targets).

% finds the average of both wgds of a possible match
find_avg_wgd(Name, Target, AvgWgd) :-
	weighted_glanian_distance(Name, Target, D1),
	weighted_glanian_distance(Target, Name, D2),
	AvgWgd is ((D1 + D2) / 2).

% 3.9 find_my_best_match(Name, Distances, Activities, Cities, Targets) 25 points
find_my_best_match(Name, Distances, Activities, Cities, Targets) :-
	% to find targets
	glanian(Name, _, Features),
	dislikes(Name, DActs, DCities, Limits),
	likes(Name, LActs, _),
	adjust_limits(Limits, Adj),
	% Target’s gender should be in the expected gender list of Name.
	find_weighted_targets(Name, _, TList),
	findall(B, (member(B, TList),
				% B’s features should be in the tolerance limits of Name.
				glanian(B, _, Feats),
				comp_lims(Adj, Feats),
				% Name’s features should be in the tolerance limits of B.
				dislikes(B, DActsOfB, _, TLim),
				adjust_limits(TLim, TAdj),
				comp_lims(TAdj, Features),
				% Name’s gender should be in the expected gender list of B.
				find_possible_targets(B, _, BTList),
				member(Name, BTList),
				% Name and B should not have any previous oldrelation.
				not(old_relation([Name|B])),
				% The intersection between Name’s DislikedActivities and B’s LikedActivities should not be more than two.
				(likes(B, LActsOfB, _), intersection(DActs, LActsOfB, Intr), length_of(Intr, X), X<3),
				% The intersection between Name’s LikedActivities and B’s DislikedActivities should not be more than two.
				(intersection(DActsOfB, LActs, Intr2), length_of(Intr2, Y), Y<3)
				), BetaTargets),
	findall(D-T, (member(T, BetaTargets), find_avg_wgd(Name, T, D)), BetaUnsorted),
	sort(1, @=<, BetaUnsorted, BetaSorted),
	findall(D-A-C-T, (member(D-T, BetaSorted),
					merge_possible_cities(Name, T, Cs),
					member(C, Cs),
					is_compitable(Name, A, C),
					is_compitable(T, A, C),
					dislikes(T, DActsOfT, DCitiesOfT, _),
					not(member(A, DActs)),
					not(member(A, DActsOfT)),
					not(member(C, DCities)),
					not(member(C, DCitiesOfT))
					), AlphaUnsorted),
	sort(1, @<, AlphaUnsorted, AlphaSorted),
	findall(D, member(D-A-C-T, AlphaSorted), Distances),
	findall(A, member(D-A-C-T, AlphaSorted), Activities),
	findall(C, member(D-A-C-T, AlphaSorted), Cities),
	findall(T, member(D-A-C-T, AlphaSorted), Targets).

% finds the top 10 matches
find_all_matches(Name, Result) :-
	glanian(Name, _, Features),
	dislikes(Name, DActs, _, Limits),
	likes(Name, LActs, _),
	adjust_limits(Limits, Adj),
	% Target’s gender should be in the expected gender list of Name.
	find_weighted_targets(Name, _, TList),
	findall(B, (member(B, TList),
				% B’s features should be in the tolerance limits of Name.
				glanian(B, _, Feats),
				comp_lims(Adj, Feats),
				% Name’s features should be in the tolerance limits of B.
				dislikes(B, DActsOfB, _, TLim),
				adjust_limits(TLim, TAdj),
				comp_lims(TAdj, Features),
				% Name’s gender should be in the expected gender list of B.
				find_possible_targets(B, _, BTList),
				member(Name, BTList),
				% Name and B should not have any previous oldrelation.
				not(old_relation([Name|B])),
				% The intersection between Name’s DislikedActivities and B’s LikedActivities should not be more than two.
				(likes(B, LActsOfB, _), intersection(DActs, LActsOfB, Intr), length_of(Intr, X), X<3),
				% The intersection between Name’s LikedActivities and B’s DislikedActivities should not be more than two.
				(intersection(DActsOfB, LActs, Intr2), length_of(Intr2, Y), Y<3)
				), BetaTargets),
	findall(D-T, (member(T, BetaTargets), find_avg_wgd(Name, T, D)), BetaUnsorted),
	sort(1, @=<, BetaUnsorted, Result).
	
% bonus top 10 list
top_ten :-
	findall(A, glanian(A, _, _), Glanians),
	findall(D-T-N, (member(N, Glanians), find_all_matches(N, AllMatches), member(D-T, AllMatches)), Temp),
	findall(D-T-N, (member(D-T-N, Temp), not(member(D-N-T))), OmegaUnsorted),
	sort(1, @<, OmegaUnsorted, OmegaSorted),
	take(10, OmegaSorted, Answer),
	write_list_to_file('top10.txt', Answer).


	










