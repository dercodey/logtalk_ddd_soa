:- module(vet_clinic, []).


:- protocol(aggregate_root).
	:- public(id/1).
:- end_protocol.

:- protocol(repository).
	:- public([get_by_id/2,
		get_all/1,
		add/2,
		update/1,
		delete/1]).
:- end_protocol.

:- protocol(appointment_application).
	:- public([list_all_appointments/1,
			create_appointment/3,
			update_appointment/2,
			delete_appointment/1]).
:- end_protocol.


/************************************************************
%!	appointment_application(_Repository) is det
%
%	note that we don't use a bus, as the repository is the only holder
%	of state
**************************************************************/

:- object(appointment_application(_Repository),
		 implements(appointment_application)).

	%!		list(_) is det
	%
	%

	list_all_appointments(All_Appointments) :-	
		this(appointment_application(Repository)).

	:- info(list_all_appointments/1, [comment(query)]).

	%!		update_appointment(_) is det
	%
	%

	update_appointment(Id, New_Time) :-
			this(appointment_application(Repository)),
			Repository::get_by_id(Id, Appointment),
			Appointment::update_scheduled_time(New_Time),
			Repository::update(Appointment).

	:- info(update_appointment/2, [comment(command)]).

:- end_object.



/*********************************************************
%!  appointment_repository(_Current, _Next) is not det
%
%	note that we need a bus because
**********************************************************/

:- object(appointment_repository(_Current_Dict -> _Next_Dict),
		 implements(repository)).

	%% TODO: this doesn't work
	:- initialization((
		   this(appointment_repository(Current_Dict -> _)),
		   var(Current_Dict) ->
			Current_Dict = appointment_repository{}; true)).

	%!
	%
	%
	get_by_id(Id, Appointment) :-
			this(appointment_repository(Current_Dict -> _)),
			get_dict(Id, Current_Dict, Appointment).

	:- info(get_by_id/2, [comment(query)]).

	%!
	%
	%
	get_all(All_Appointments) :-
	    	this(appointment_repository(Current_Dict -> _)),
			All_Appointments = Current_Dict.

	%!
	%
	%
	add(New_Appointment, New_Appointment) :-
			is_dict(New_Appointment, appointment),
			Next_Dict = Current_Dict,
			this(appointment_repository(Current_Dict -> Next_Dict)).

	%!
	%
	%
	update(Updated_Appointment) :-
	    	is_dict(Updated_Appointment, appointment),
			this(appointment_repository(Current_Dict -> Next_Dict)).
	%!
	%
	%
	delete(Id) :- true.

:- end_object.


