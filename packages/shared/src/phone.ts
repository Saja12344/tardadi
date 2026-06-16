export function normalizePhone(phone: string): string {
  const digits = phone.replace(/\D/g, "");

  if (digits.startsWith("966") && digits.length >= 12) {
    return `+${digits}`;
  }

  if (digits.startsWith("05") && digits.length === 10) {
    return `+966${digits.slice(1)}`;
  }

  if (digits.startsWith("5") && digits.length === 9) {
    return `+966${digits}`;
  }

  if (phone.startsWith("+")) {
    return `+${digits}`;
  }

  return digits;
}
