:- module(test_limit,
	  [ test_limit/0
	  ]).
:- use_module(library(plunit)).
:- use_module(library(debug)).

test_limit :-
	run_tests([ program_space
		  ]).

:- begin_tests(program_space, []).

test(fetch) :-
	module_property(user, program_size(Size)),
	assertion(Size > 1000).
test(fetch, fail) :-
	module_property(user, program_space(_)).
test(too_low, error(permission_error(limit, program_space, user))) :-
	set_module(user:program_space(1000)).
test(retract, Size == Size0) :-
	set_module(program_space_limit:program_space(0)),
	dynamic(program_space_limit:test/0),
	module_property(program_space_limit, program_size(Size0)),
	assertz(program_space_limit:test),
	retract(program_space_limit:test),
	module_property(program_space_limit, program_size(Size)).
test(abolish, Size == Size0) :-
	set_module(program_space_limit:program_space(0)),
	module_property(program_space_limit, program_size(Size0)),
	assertz(program_space_limit:test),
	abolish(program_space_limit:test/0),
	module_property(program_space_limit, program_size(Size)).
test(assert, [cleanup(abolish(program_space_limit:test/0))]) :-
	set_module(program_space_limit:program_space(1000)),
	module_property(program_space_limit, program_space(Space)),
	assertion(Space == 1000),
	assertz(program_space_limit:test).
test(overflow, [ cleanup(abolish(program_space_limit:test/1)),
		 error(resource_error(program_space))
	       ]) :-
	set_module(program_space_limit:program_space(1000)),
	forall(between(1, 100, X),
	       assertz(program_space_limit:test(X))).
test(repeat, [ cleanup(abolish(program_space_limit:test/1))
	     ]) :-
	set_module(program_space_limit:program_space(100000)),
	module_property(program_space_limit, program_size(Size0)),
	forall(between(1, 100, _),
	       ( forall(between(1, 100, X),
			assertz(program_space_limit:test(X))),
		 retractall(program_space_limit:test(_)),
		 module_property(program_space_limit, program_size(Size)),
		 assertion(Size0 == Size),
		 Size0 == Size		% no warning if optimized away
	       )).

:- end_tests(program_space).
