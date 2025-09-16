module MyModule::StudyHelp {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;
    
    /// Struct representing a study help session
    struct StudySession has store, key {
        tutor: address,           // Address of the tutor
        rate_per_hour: u64,       // Token rate per hour
        total_earned: u64,        // Total tokens earned by tutor
        students: vector<address>, // List of students who paid for help
    }
    
    /// Function to register as a tutor and set hourly rate
    public fun register_tutor(tutor: &signer, rate_per_hour: u64) {
        let tutor_addr = signer::address_of(tutor);
        let session = StudySession {
            tutor: tutor_addr,
            rate_per_hour,
            total_earned: 0,
            students: vector::empty<address>(),
        };
        move_to(tutor, session);
    }
    
    /// Function for students to pay for study help
    public fun pay_for_help(student: &signer, tutor_address: address, hours: u64) acquires StudySession {
        let student_addr = signer::address_of(student);
        let session = borrow_global_mut<StudySession>(tutor_address);
        
        // Calculate payment amount
        let payment_amount = session.rate_per_hour * hours;
        
        // Transfer tokens from student to tutor
        let payment = coin::withdraw<AptosCoin>(student, payment_amount);
        coin::deposit<AptosCoin>(tutor_address, payment);
        
        // Update session data
        session.total_earned = session.total_earned + payment_amount;
        
        // Add student to list if not already present
        if (!vector::contains(&session.students, &student_addr)) {
            vector::push_back(&mut session.students, student_addr);
        }
    }
}