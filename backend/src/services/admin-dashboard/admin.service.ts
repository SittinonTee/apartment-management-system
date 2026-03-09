import pool from "../database";

export const getUserData = async () => {
  const [rows] = await (pool as any).query(`
    SELECT user_id, firstname, lastname, email, roles, status
    FROM users
  `);

  return (rows as any[]).map((u: any) => ({
    id: u.user_id,
    firstname: u.firstname,
    lastname: u.lastname,
    email: u.email,
    role: u.roles,
    status: u.status
  }));
};
