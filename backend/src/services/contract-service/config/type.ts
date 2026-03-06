export interface Contract {
    contracts_id: number;
    room_id: string;
    rate_id: number;
    user_id: number;
    start_date: string;
    end_date: string;
    status: string;

    // Joined fields from Room
    room_number?: string;
    floor?: number;
    room_type?: string;

    // Joined fields from Rate
    rate_room?: string;
    rate_water?: string;
    rate_electric?: string;
}