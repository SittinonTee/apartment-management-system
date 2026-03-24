export interface USERCONTRACT {
    user_id: number;
    firstname: string;
    lastname: string;
    phone: string;
    emergency_phone: string;
    email: string;
    roles: string;
    room_number: string;
    floor: number;
    rate_room: number;
    rate_water: number;
    rate_electric: number;
    contract_no: string;
    start_date: Date;
    end_date: Date;
    deposit: number;
    bills_no: number;
    user_status: string;
    contract_status: string;
}
