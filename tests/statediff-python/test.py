import numpy as np
from statediff import IOUringStream, StateDiffClient

chunk_size = 512
data_size = 1024 * 1024
error_tol = 1e-4
dtype = 'f'
root_level = 1

reader = IOUringStream("data_0.dat", chunk_size // 4)
client = StateDiffClient(0, reader, data_size, error_tol, dtype, chunk_size, root_level, True)

test_data = np.random.rand(data_size // 4).astype(np.float32)
client.create(test_data)

print("Client initialized and tree created")