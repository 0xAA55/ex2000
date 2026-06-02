import sys

def remove_rich_header(path):
	with open(path, "rb+") as f:
		data = bytearray(f.read())

		if data[:2] != b"MZ":
			raise ValueError("Not MZ EXE")

		e_lfanew = int.from_bytes(data[0x3C:0x40], "little")
		pe_offset = e_lfanew

		rich_pos = -1
		for i in range(0x40, pe_offset - 4):
			if data[i:i+4] == b"Rich":
				rich_pos = i
				break

		if rich_pos == -1:
			print("No Rich header was found")
			return

		rich_start = rich_pos - 8
		if rich_start < 0:
			rich_start = 0

		length = pe_offset - rich_start
		data[rich_start:pe_offset] = b"\x00" * length

		data[0x3C:0x40] = pe_offset.to_bytes(4, "little")

		f.seek(0)
		f.write(data)

	print("Rich is removed")

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Usage: python unrich.py your.exe")
	else:
		remove_rich_header(sys.argv[1])
