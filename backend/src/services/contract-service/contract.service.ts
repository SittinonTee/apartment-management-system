import pool from '../database';
import { Contract } from './config/type';

export const getContractByUserId = async (userId: number) => {
    const query = `
        SELECT 
            c.*, 
            r.room_number, r.floor, r.room_type,
            rt.rate_room, rt.rate_water, rt.rate_electric
        FROM Contracts c
        JOIN Room r ON c.room_id = r.room_id
        JOIN Rate rt ON c.rate_id = rt.rate_id
        WHERE c.user_id = ? AND c.status = 'ACTIVE'
        LIMIT 1
    `;
    const [rows] = await pool.query(query, [userId]) as [Contract[], any];
    return rows[0] || null;
};
