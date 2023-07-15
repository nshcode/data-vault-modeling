-- =====================================================
-- Performs the initial data loadung of the tbales 
-- based on the non-historized link modeling (version2).
-- =====================================================

-- ====================
-- Aircraft <--> Seat
-- ====================

-- Aircarft-Hub
insert into dv1.h_aircraft (
	 hk_aircraft
	,aircraft_code
	,load_date_ts
) select 
	 md5(upper(trim(aircraft_code)))
	,aircraft_code 
	,current_timestamp(0)
  from bookings.aircrafts;

 -- Aircraft-Satellite
 insert into dv1.s_aircraft (
 	 hk_aircraft
	,load_date_ts
	,model
	,range
 ) select 
 	 md5(upper(trim(aircraft_code)))
 	,current_timestamp(0)
 	,model ->> 'en' as model
 	,range
 from bookings.aircrafts_data;
  
-- Seat-Hub
 insert into dv1.h_seat (
 	 hk_seat
	,aircraft_code
	,seat_no
	,load_date_ts
 ) select 
 	 md5(
 	 	upper(trim(aircraft_code)) 
 	 	|| '|'
 	 	|| upper(trim(seat_no))
 	 )
 	,aircraft_code
 	,seat_no 
 	,current_timestamp(0)
   from bookings.seats;
   
 -- Seat-Satellite
 insert into dv1.s_seat (
 	 hk_seat
	,load_date_ts
	,fare_conditions
 ) select
 	md5(
 		upper(trim(aircraft_code)) 
 	 	|| '|'
 	 	|| upper(trim(seat_no))
 	 )
 	,current_timestamp(0)
 	,fare_conditions 
  from bookings.seats;
 
 -- Aircraft-Seat-Link
 insert into dv1.l_aircraft_seat (
 	lhk_aircraft_seat
	,hk_aircraft
	,hk_seat
	,load_date_ts
 ) select 
 	md5(
 		upper(trim(aircraft_code))
 		|| '|'
 		|| upper(trim(aircraft_code))
 		|| '|'
 		|| upper(trim(seat_no))
 	)
 	,md5(upper(trim(aircraft_code)))
 	,md5(
 		upper(trim(aircraft_code)) 
 	 	|| '|'
 	 	|| upper(trim(seat_no))
 	 )
 	,current_timestamp(0)
  from bookings.seats; 
 
-- ==================================
-- Flight <--> Airport <--> Aircraft
-- ==================================

-- Airport-Hub
insert into dv1.h_airport (
	 hk_airport
	,airport_code
	,load_date_ts
) select 
	md5(upper(trim(airport_code)))
	,airport_code
	,current_timestamp(0)
  from bookings.airports;
 
 -- Airport-Satellite
 insert into dv1.s_airport (
 	hk_airport
	,load_date_ts
	,airport_name 
	,city
	,coordinates
	,timezone
) select 
	 md5(upper(trim(airport_code)))
	,current_timestamp(0)
	,airport_name 
	,city
	,coordinates
	,timezone
 from bookings.airports;

-- =======================================================
-- ======================================================= 

-- Flight-Airport-Aircraft-Link
insert into dv1.l_flight_airport_aircraft (
	lhk_flight_airport_aircraft
	,hk_departure_airport
	,hk_arrival_airport
	,hk_aircraft
	,flight_id
	,load_date_ts    
) select 
	md5(
		upper(trim(flight_id::varchar)) 
		|| '|'
		|| upper(trim(departure_airport))
		|| '|'
		|| upper(trim(arrival_airport))
		|| '|'
		|| upper(trim(aircraft_code))
	)
	,md5(upper(trim(departure_airport)))
	,md5(upper(trim(arrival_airport)))
	,md5(upper(trim(aircraft_code)))
	,flight_id
	,current_timestamp(0)
 from bookings.flights; 

-- Flight-Satellite
insert into dv1.s_flight (
	 lhk_flight_airport_aircraft
	,load_date_ts
	,flight_no
	,scheduled_departure
	,scheduled_arrival
	,actual_departure
	,actual_arrival
	,status    
) select 
	md5(
		upper(trim(flight_id::varchar)) 
		|| '|'
		|| upper(trim(departure_airport))
		|| '|'
		|| upper(trim(arrival_airport))
		|| '|'
		|| upper(trim(aircraft_code))
	)
	,current_timestamp(0)
	,flight_no
	,scheduled_departure
	,scheduled_arrival
	,actual_departure
	,actual_arrival
	,status
 from bookings.flights;


-- ==================
-- Ticket <--> Flight 
-- ==================

-- Ticket-Hub
insert into dv1.h_ticket (
	hk_ticket
	,ticket_no
	,load_date_ts
) select 
	 md5(upper(trim(ticket_no)))
	,ticket_no
	,current_timestamp(0)
   from bookings.tickets;
  
  -- Ticket-Satellite
insert into dv.s_ticket (
	 hk_ticket
	,load_date_ts
	,passenger_id
	,passenger_name
	,passenger_phone
	,passenger_email
) select
 	md5(upper(trim(ticket_no)))
 	,current_timestamp(0)
 	,passenger_id
	,passenger_name
 	,contact_data ->> 'phone'
	,contact_data ->> 'email'
 from bookings.tickets;
  
 insert into dv1.l_ticket_flight_airport_aircraft (
 	lhk_ticket_flight_airport_aircraft
 	,hk_ticket
 	,lhk_flight_airport_aircraft
 	,load_date_ts
 ) select
 	md5(
		upper(trim(f.flight_id::varchar)) 
		|| '|'
		|| upper(trim(f.departure_airport))
		|| '|'
		|| upper(trim(f.arrival_airport))
		|| '|'
		|| upper(trim(f.aircraft_code))
		|| '|'
		|| upper(trim(tf.ticket_no))
	)
	,md5(upper(trim(tf.ticket_no)))
	,md5(
		upper(trim(f.flight_id::varchar)) 
		|| '|'
		|| upper(trim(f.departure_airport))
		|| '|'
		|| upper(trim(f.arrival_airport))
		|| '|'
		|| upper(trim(f.aircraft_code))
	)
	,current_timestamp(0)
  from bookings.flights f
  join bookings.ticket_flights tf 
  	on f.flight_id = tf.flight_id;

-- s_ticket_flight_airport_aircraft
insert into dv1.s_ticket_flight_airport_aircraft (
	lhk_ticket_flight_airport_aircraft
	,load_date_ts
	,fare_conditions
	,amount
) select 
	md5(
		upper(trim(f.flight_id::varchar)) 
		|| '|'
		|| upper(trim(f.departure_airport))
		|| '|'
		|| upper(trim(f.arrival_airport))
		|| '|'
		|| upper(trim(f.aircraft_code))
		|| '|'
		|| upper(trim(tf.ticket_no))
	)
	,current_timestamp(0)
	,tf.fare_conditions
	,tf.amount 
 from bookings.flights f
 join bookings.ticket_flights tf 
  	on f.flight_id = tf.flight_id;
 
  -- s_boarding_ticket_flight_port_aircraft 
 insert into dv1.s_boarding_ticket_flight_port_aircraft (
 	lhk_ticket_flight_airport_aircraft
 	,load_date_ts
 	,boarding_no
 	,seat_no 
 ) select
 	md5(
 		upper(trim(f.flight_id::varchar)) 
		|| '|'
		|| upper(trim(f.departure_airport))
		|| '|'
		|| upper(trim(f.arrival_airport))
		|| '|'
		|| upper(trim(f.aircraft_code))
		|| '|'
		|| upper(trim(bp.ticket_no))
	)
	,current_timestamp(0)
	,bp.boarding_no 
	,bp.seat_no 
  from bookings.flights f
  join bookings.boarding_passes bp 
  	on f.flight_id = bp.flight_id; 
-- =======================================================
-- =======================================================

-- Booking-Hub
insert into dv1.h_booking (
	hk_booking
	,book_ref
	,load_date_ts
) select 
	md5(upper(trim(book_ref)))
	,book_ref 
	,current_timestamp(0)
 from bookings.bookings;

-- Booking-Satellite
insert into dv1.s_booking (
	hk_booking
	,load_date_ts
	,book_date
	,total_amount
) select 
	md5(upper(trim(book_ref)))
	,current_timestamp(0)
	,book_date
	,total_amount 
 from bookings.bookings; 


-- -- Booking-Ticket-Link
insert into dv1.l_booking_ticket (
	lhk_booking_ticket
	,hk_booking
	,hk_ticket
	,load_date_ts
) select
	md5 (
		upper(trim(ticket_no))
		|| '|'
		|| upper(trim(book_ref))
	)
	,md5(upper(trim(book_ref)))
	,md5(upper(trim(ticket_no)))
	,current_timestamp(0)
 from tickets; 