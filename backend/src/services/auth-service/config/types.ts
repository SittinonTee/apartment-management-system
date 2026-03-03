export interface USERACCOUNT {
    user_id?: number;
    username: string;
    password: string;
    firstname?: string;
    lastname?: string;
    phone?: string;
    email: string;
    roles: 'ADMIN' | 'TECHNICIAN' | 'TENANT';
    status: 'ACTIVE' | 'INACTIVE' | 'BANNED';
    created_at?: Date;
    id_keycard?: string;
    emergency_contact?: string;
    invite_code: string;
}
