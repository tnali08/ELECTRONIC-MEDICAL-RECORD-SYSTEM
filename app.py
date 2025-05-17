import getpass
from db_connector import call_stored_procedure
from utils import display_results, hash_password

# Global variables
current_user = None
current_role = None

def main_menu():
    """Display the main menu options"""
    print("\n==== University Health Clinic EMR System ====")
    print("1. Provider Login")
    print("2. Patient Login")
    print("3. Exit")
    return input("\nSelect an option: ")

def provider_menu():
    """Display provider menu options"""
    print("\n==== Provider Portal ====")
    print("1. View My Schedule")
    print("2. Search Patients")
    print("3. View Patient Details")
    print("4. Record Patient Visit")
    print("5. Prescribe Medication")
    print("6. Order Lab Test")
    print("7. View Billing Information")
    print("8. Run Reports")
    print("9. Log Out")
    return input("\nSelect an option: ")

def patient_menu():
    """Display patient menu options"""
    print("\n==== Patient Portal ====")
    print("1. View My Appointments")
    print("2. View My Medical Records")
    print("3. View My Prescriptions")
    print("4. View My Lab Results")
    print("5. View My Billing") 
    print("6. Log Out")
    return input("\nSelect an option: ")

def login(role):
    """Handle user login"""
    global current_user, current_role
    
    username = input("Username: ")
    password = getpass.getpass("Password: ")
    password_hash = hash_password(password)
    
    # Connect directly to database instead of using stored procedure
    from db_connector import get_connection
    from mysql.connector import Error
    
    connection = get_connection()
    if not connection:
        print("\nDatabase connection error. Please try again later.")
        return False
        
    cursor = connection.cursor()
    try:
        # Query the Users table directly (matching your database structure)
        query = """
        SELECT user_id, username, email, provider_id 
        FROM Users 
        WHERE username = %s AND password_hash = %s AND active = TRUE
        """
        cursor.execute(query, (username, password_hash))
        user_data = cursor.fetchone()
        
        if user_data:
            user_id = user_data[0]  # First column is user_id
            
            # Set the current user context
            cursor.execute("SET @current_user_id = %s", (user_id,))
            connection.commit()
            
            current_user = user_id
            current_role = role
            
            print("\nLogin successful!")
            return True
        else:
            print("\nInvalid username or password. Please try again.")
            return False
            
    except Error as e:
        print(f"\nLogin error: {e}")
        return False
    finally:
        cursor.close()
        connection.close()

def provider_view_schedule():
    """View the provider's schedule"""
    date_input = input("\nEnter date (YYYY-MM-DD) or press Enter for today: ")
    if not date_input:
        from datetime import date
        date_input = date.today().isoformat()
    
    results = call_stored_procedure("sp_GetProviderSchedule", [current_user, date_input])
    display_results(results)

def search_patients():
    """Search for patients"""
    search_term = input("\nEnter search term (name, ID, email, etc.): ")
    results = call_stored_procedure("sp_SearchPatients", [search_term, 10, 0])
    display_results(results)

def view_patient_details():
    """View detailed patient information"""
    patient_id = input("\nEnter patient ID: ")
    try:
        patient_id = int(patient_id)
        results = call_stored_procedure("sp_GetPatientDetails", [patient_id])
        display_results(results)
    except ValueError:
        print("Invalid patient ID. Please enter a number.")

def record_patient_visit():
    """Record a new patient visit"""
    try:
        # Get required information
        appointment_id = input("Enter appointment ID (leave blank if not applicable): ")
        appointment_id = int(appointment_id) if appointment_id else None
        
        patient_id = int(input("Enter patient ID: "))
        facility_id = int(input("Enter facility ID: "))
        visit_type = input("Enter visit type (e.g., Sick Visit, Follow-up): ")
        chief_complaint = input("Enter chief complaint: ")
        
        # Call stored procedure
        results = call_stored_procedure("sp_RecordVisit", 
                                      [appointment_id, patient_id, current_user, 
                                       facility_id, visit_type, chief_complaint])
        display_results(results)
        
        # Ask if user wants to record vitals
        if input("Record vitals? (y/n): ").lower() == 'y':
            visit_id = results[0][0][0][0]  # Extract visit_id from results
            record_vitals(visit_id)
        
    except ValueError:
        print("Invalid input. Please enter numeric values where required.")
    except Exception as e:
        print(f"Error recording visit: {e}")

def record_vitals(visit_id):
    """Record patient vitals for a visit"""
    try:
        # Get vitals
        temperature = input("Temperature (°C): ")
        temperature = float(temperature) if temperature else None
        
        bp_systolic = input("Blood Pressure Systolic: ")
        bp_systolic = int(bp_systolic) if bp_systolic else None
        
        bp_diastolic = input("Blood Pressure Diastolic: ")
        bp_diastolic = int(bp_diastolic) if bp_diastolic else None
        
        pulse = input("Pulse Rate: ")
        pulse = int(pulse) if pulse else None
        
        resp_rate = input("Respiratory Rate: ")
        resp_rate = int(resp_rate) if resp_rate else None
        
        height = input("Height (cm): ")
        height = float(height) if height else None
        
        weight = input("Weight (kg): ")
        weight = float(weight) if weight else None
        
        o2_sat = input("Oxygen Saturation (%): ")
        o2_sat = int(o2_sat) if o2_sat else None
        
        pain = input("Pain Level (0-10): ")
        pain = int(pain) if pain else None
        
        # Call stored procedure
        results = call_stored_procedure("sp_RecordVitals",
                                      [visit_id, temperature, bp_systolic, bp_diastolic,
                                       pulse, resp_rate, height, weight, o2_sat, pain, current_user])
        display_results(results)
        
    except ValueError:
        print("Invalid input. Please enter numeric values.")
    except Exception as e:
        print(f"Error recording vitals: {e}")

def patient_view_appointments():
    """View patient's appointments"""
    results = call_stored_procedure("vw_PatientAppointments", [current_user])
    display_results(results)

def main():
    """Main application function"""
    global current_user, current_role
    
    print("Welcome to the University Health Clinic EMR System")
    
    try:
        while True:
            if not current_user:
                choice = main_menu()
                
                if choice == "1":
                    login("provider")
                elif choice == "2":
                    login("patient")
                elif choice == "3":
                    print("\nExiting system. Thank you for using the EMR system.")
                    break
                else:
                    print("\nInvalid option. Please try again.")
            
            elif current_role == "provider":
                choice = provider_menu()
                
                if choice == "1":
                    provider_view_schedule()
                elif choice == "2":
                    search_patients()
                elif choice == "3":
                    view_patient_details()
                elif choice == "4":
                    record_patient_visit()
                elif choice == "9":
                    current_user = None
                    current_role = None
                    print("\nLogged out successfully.")
                else:
                    print("\nOption not implemented yet or invalid selection.")
            
            elif current_role == "patient":
                choice = patient_menu()
                
                if choice == "1":
                    patient_view_appointments()
                elif choice == "6":
                    current_user = None
                    current_role = None
                    print("\nLogged out successfully.")
                else:
                    print("\nOption not implemented yet or invalid selection.")
    
    except KeyboardInterrupt:
        print("\n\nProgram interrupted. Exiting...")
    finally:
        print("\nThank you for using the University Health Clinic EMR System.")

if __name__ == "__main__":
    main()