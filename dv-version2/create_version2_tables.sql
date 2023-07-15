-- ========================================================
-- The Model is based on the non-historized link modeling. 
-- ========================================================


drop schema if exists dv1 cascade;
create schema dv1;

-- Aircarft-Hub
create table dv1.h_aircraft (
	 hk_aircraft    char(32)  not null
	,aircraft_code  char(3)   not null
	,load_date_ts   timestamp not null
	,constraint h_aircraft_pk
		primary key (hk_aircraft)
);

-- Aircarft-Satellite
create table dv1.s_aircraft (
	 hk_aircraft  char(32)    not null
	,load_date_ts timestamp   not null
	,model        varchar(25) not null
	,range integer
	,constraint s_aircraft_pk 
		primary key (hk_aircraft, load_date_ts)
	,constraint s_aircraft_h_aircraft_fk
		foreign key (hk_aircraft)
		references dv1.h_aircraft(hk_aircraft)
);

-- Seat-Hub
create table dv1.h_seat (
	 hk_seat        char(32)    not null
	,aircraft_code  char(3)     not null
	,seat_no        varchar(4)  not null
	,load_date_ts   timestamp   not null
	,constraint h_seat_pk 
		primary key (hk_seat)
);

-- Seat-Satellite
create table dv1.s_seat (
	 hk_seat         char(32)    not null
	,load_date_ts    timestamp   not null
	,fare_conditions varchar(10) not null
	,constraint s_seat_pk
		primary key (hk_seat, load_date_ts)
	,constraint s_seat_h_seat_fk
		foreign key (hk_seat)
		references dv1.h_seat(hk_seat)
);

-- Aircraft-Seat-Link
create table dv1.l_aircraft_seat (
	 lhk_aircraft_seat char(32)    not null
	,hk_aircraft       char(32)    not null
	,hk_seat           char(32)    not null
	,load_date_ts      timestamp   not null
	,constraint l_aircraft_seat_pk
		primary key (lhk_aircraft_seat)
	,constraint l_aircraft_seat_h_aircraft_fk
		foreign key (hk_aircraft) 
		references dv1.h_aircraft (hk_aircraft)
	,constraint l_aircraft_seat_h_seat_fk
		foreign key (hk_seat)
		references dv1.h_seat (hk_seat)
);

-- =======================================================
-- ======================================================= 

-- Airport-Hub
create table dv1.h_airport (
	 hk_airport   char(32)  not null
	,airport_code char(3)   not null
	,load_date_ts timestamp not null
	,constraint h_airport_pk
		primary key (hk_airport)
);

-- Airport-Satellite
create table dv1.s_airport (
	 hk_airport   char(32)  not null
	,load_date_ts timestamp not null
	,airport_name text      not null 
	,city         text      not null
	,coordinates  point     not null
	,timezone     text      not null
	,constraint s_airport_pk 
		primary key (hk_airport, load_date_ts)
	,constraint s_airport_h_airport_fk
		foreign key (hk_airport)
		references dv1.h_airport(hk_airport)
);

-- =======================================================
-- ======================================================= 


-- Flight-Airport-Aircraft-Link
create table dv1.l_flight_airport_aircraft (
	 lhk_flight_airport_aircraft char(32)  not null
	,hk_departure_airport        char(32)  not null
	,hk_arrival_airport          char(32)  not null
	,hk_aircraft                 char(32)  not null
	,flight_id                   integer   not null
	,load_date_ts                timestamp not null
	,constraint l_flight_airport_aircraft_pk
		primary key (lhk_flight_airport_aircraft)
	,constraint l_flight_airport_aircraft_h_departure_fk
		foreign key (hk_departure_airport)
		references dv1.h_airport(hk_airport)
	,constraint l_flight_airport_aircraft_h_arrival_fk
		foreign key (hk_arrival_airport)
		references dv1.h_airport(hk_airport)
	,constraint l_flight_airport_aircraft_h_aircraft_fk
		foreign key (hk_aircraft)
		references dv1.h_aircraft(hk_aircraft)
);

-- Flight-Satellite
create table dv1.s_flight (
	 lhk_flight_airport_aircraft            char(32)     not null
	,load_date_ts         timestamp    not null
	,flight_no             char(6)     not null
	,scheduled_departure  timestamptz  not null
	,scheduled_arrival    timestamptz  not null
	,actual_departure     timestamptz
	,actual_arrival       timestamptz
	,status               varchar(20)
	,constraint s_flight_pk 
		primary key (lhk_flight_airport_aircraft, load_date_ts)
	,constraint s_flight_l_flight_airport_aircraft_fk
		foreign key (lhk_flight_airport_aircraft)
		references dv1.l_flight_airport_aircraft(lhk_flight_airport_aircraft)
);

-- Ticket-Hub
create table dv1.h_ticket (
	 hk_ticket    char(32)  not null
	,ticket_no    char(13)  not null
	,load_date_ts timestamp not null
	,constraint h_ticket_pk 
		primary key (hk_ticket)
);

-- Ticket-Satellite
create table dv1.s_ticket (
	 hk_ticket       char(32)    not null
	,load_date_ts    timestamp   not null
	,passenger_id    varchar(20) not null
	,passenger_name  text        not null
	,passenger_phone text
	,passenger_email text 
	,constraint s_ticket_pk
		primary key (hk_ticket, load_date_ts)
	,constraint s_ticket_h_ticket_fk
		foreign key (hk_ticket)
		references dv1.h_ticket(hk_ticket)
);

-- Ticket-Flight-Link
create table dv1.l_ticket_flight_airport_aircraft (
	lhk_ticket_flight_airport_aircraft char(32)  not null
	,hk_ticket                         char(32)  not null
	,lhk_flight_airport_aircraft       char(32)  not null
	,load_date_ts                      timestamp not null
	,constraint l_ticket_flight_airport_aircraft_pk
		primary key (lhk_ticket_flight_airport_aircraft)
	,constraint l_ticket_flight_airport_aircraft_h_ticket_fk
		foreign key (hk_ticket)
		references dv1.h_ticket (hk_ticket)
	,constraint l_ticket_flight_airport_aircraft_l_flight_airport_aircraft_fk
		foreign key (lhk_flight_airport_aircraft)
		references dv1.l_flight_airport_aircraft (lhk_flight_airport_aircraft)
);


create table dv1.s_ticket_flight_airport_aircraft (
	lhk_ticket_flight_airport_aircraft char(32)       not null
	,load_date_ts                      timestamp      not null
	,fare_conditions                   varchar(10)    not null
	,amount                            numeric(10, 2) not null
	,constraint s_ticket_flight_airport_aircraft_pk
		primary key (lhk_ticket_flight_airport_aircraft, load_date_ts)
	,constraint s_ticket_flight_airport_aircraft_l_fk
		foreign key (lhk_ticket_flight_airport_aircraft)
		references dv1.l_ticket_flight_airport_aircraft (lhk_ticket_flight_airport_aircraft)
);

create table dv1.s_boarding_ticket_flight_port_aircraft (
	lhk_ticket_flight_airport_aircraft char(32)    not null
	,load_date_ts                      timestamp   not null
	,boarding_no                       integer     not null
	,seat_no                           varchar(4)  not null
	,constraint s_boarding_ticket_flight_port_aircraft_pk
		primary key (lhk_ticket_flight_airport_aircraft, load_date_ts)
	,constraint s_boarding_ticket_flight_port_aircraft_l_fk
		foreign key (lhk_ticket_flight_airport_aircraft)
		references dv1.l_ticket_flight_airport_aircraft (lhk_ticket_flight_airport_aircraft)
);

-- =======================================================
-- =======================================================

-- Booking-Hub
create table dv1.h_booking (
	 hk_booking    char(32)  not null
	,book_ref      char(6)   not null
	,load_date_ts timestamp  not null
	,constraint h_booking_pk 
		primary key (hk_booking)
);

-- Booking-Satellite
create table dv1.s_booking (
	hk_booking    char(32)       not null
	,load_date_ts timestamp      not null
	,book_date    date           not null
	,total_amount numeric(10, 2) not null
	,constraint s_booking_pk
		primary key (hk_booking, load_date_ts)
	,constraint s_booking_h_booking_fk
		foreign key (hk_booking)
		references dv1.h_booking(hk_booking)
);

-- Booking-Ticket-Link
create table dv1.l_booking_ticket (
	lhk_booking_ticket char(32)  not null
	,hk_booking        char(32)  not null
	,hk_ticket         char(32)  not null
	,load_date_ts      timestamp not null
	,constraint l_booking_ticket_pk 
		primary key (lhk_booking_ticket)
	,constraint l_booking_ticket_h_booking_fk
		foreign key (hk_booking)
		references dv1.h_booking(hk_booking)
	,constraint l_booking_ticket_h_ticket_fk
		foreign key (hk_ticket)
		references dv1.h_ticket(hk_ticket)
);
