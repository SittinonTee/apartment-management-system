import { z } from "zod";

export const getMyBillsSchema = z.object({});

export const processPaymentSchema = z.object({
	billId: z.coerce.number().int().positive(),
});

export type V_ProcessPayment = z.infer<typeof processPaymentSchema>;
