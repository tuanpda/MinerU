# Copyright (c) Opendatalab. All rights reserved.
import os

from .base import DataReader, DataWriter


def _normalize_path_for_io(path: str) -> str:
    """Make paths safe for open() on Windows (MAX_PATH / deep trees under Temp).

    Prefix with ``\\\\?\\`` (or ``\\\\?\\UNC\\``) so the OS accepts long absolute paths.
    """
    if os.name != "nt":
        return path
    abspath = os.path.abspath(path)
    if abspath.startswith("\\\\?\\"):
        return abspath
    # UNC: \\server\share\... -> \\?\UNC\server\share\...
    if abspath.startswith("\\\\"):
        return "\\\\?\\UNC\\" + abspath[2:]
    return "\\\\?\\" + abspath


class FileBasedDataReader(DataReader):
    def __init__(self, parent_dir: str = ''):
        """Initialized with parent_dir.

        Args:
            parent_dir (str, optional): the parent directory that may be used within methods. Defaults to ''.
        """
        self._parent_dir = parent_dir

    def read_at(self, path: str, offset: int = 0, limit: int = -1) -> bytes:
        """Read at offset and limit.

        Args:
            path (str): the path of file, if the path is relative path, it will be joined with parent_dir.
            offset (int, optional): the number of bytes skipped. Defaults to 0.
            limit (int, optional): the length of bytes want to read. Defaults to -1.

        Returns:
            bytes: the content of file
        """
        fn_path = path
        if not os.path.isabs(fn_path) and len(self._parent_dir) > 0:
            fn_path = os.path.join(self._parent_dir, path)

        io_path = _normalize_path_for_io(fn_path)
        with open(io_path, 'rb') as f:
            f.seek(offset)
            if limit == -1:
                return f.read()
            else:
                return f.read(limit)


class FileBasedDataWriter(DataWriter):
    def __init__(self, parent_dir: str = '') -> None:
        """Initialized with parent_dir.

        Args:
            parent_dir (str, optional): the parent directory that may be used within methods. Defaults to ''.
        """
        self._parent_dir = parent_dir

    def write(self, path: str, data: bytes) -> None:
        """Write file with data.

        Args:
            path (str): the path of file, if the path is relative path, it will be joined with parent_dir.
            data (bytes): the data want to write
        """
        fn_path = path
        if not os.path.isabs(fn_path) and len(self._parent_dir) > 0:
            fn_path = os.path.join(self._parent_dir, path)

        abs_fn = os.path.abspath(fn_path)
        parent = os.path.dirname(abs_fn)
        os.makedirs(_normalize_path_for_io(parent), exist_ok=True)

        io_path = _normalize_path_for_io(abs_fn)
        with open(io_path, 'wb') as f:
            f.write(data)
