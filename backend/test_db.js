
const mysql = require('mysql2/promise');

async function checkDb() {
    const dbUrl = 'mysql://2P3po7N97K2Miyv.root:3YgYfmnJtcODm8Q6@gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/apm-system?ssl={"rejectUnauthorized":true}';
    const connection = await mysql.createConnection(dbUrl);
    try {
        const [users] = await connection.execute('SELECT user_id, email, firstname FROM Users');
        console.log('--- Users ---');
        console.table(users);

        const [contracts] = await connection.execute('SELECT * FROM Contracts');
        console.log('\n--- Contracts ---');
        console.table(contracts);

        const [rooms] = await connection.execute('SELECT * FROM Room');
        console.log('\n--- Rooms ---');
        console.table(rooms);
    } catch (err) {
        console.error(err);
    } finally {
        await connection.end();
    }
}

checkDb();




// {
//     "status": "success",
//     "data": {
//         "contracts_id": 1,
//         "contract_no": "CNT-2024-001",
//         "identification_card": "1234567890123",
//         "address": "Bangkok",
//         "room_id": "A329_ID",
//         "user_id": 1,
//         "rate_id": 1,
//         "start_date": "2023-12-31T17:00:00.000Z",
//         "end_date": "2026-12-24T17:00:00.000Z",
//         "deposit": "15000",
//         "contractfile_url": null,
//         "status": "ACTIVE",
//         "created_by": "System",
//         "created_at": "2026-03-06T07:06:12.000Z",
//         "updated_at": "2026-03-06T07:06:12.000Z",
//         "room_number": "A329",
//         "floor": 3,
//         "room_type": "Standard",
//         "rate_room": "7500",
//         "rate_water": "18",
//         "rate_electric": "8"
//     }
// }