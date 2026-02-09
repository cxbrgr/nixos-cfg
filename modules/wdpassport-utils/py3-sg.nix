# py3_sg - Python SCSI generic library
# Source: https://pypi.org/project/py3-sg/
# Required by wdpassport-utils for sending SCSI commands to WD drives

{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "py3_sg";
  version = "0.16";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0dc5xnla38ri26mqhvrqa9adm4c82xhwxjg3lxzi32a2f10fi8rj";
  };

  # No tests in the package
  doCheck = false;

  pythonImportsCheck = [ "py3_sg" ];

  meta = with lib; {
    description = "Python SCSI generic library for sending commands to SCSI devices";
    homepage = "https://github.com/tvladyslav/py3_sg";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
