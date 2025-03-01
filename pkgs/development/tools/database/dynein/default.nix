{
  fetchFromGitHub,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "dynein";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "dynein";
    rev = "v${version}";
    hash = "sha256-QhasTFGOFOjzNKdQtA+eBhKy51O4dFt6vpeIAIOM2rQ=";
  };

  # Use system openssl.
  OPENSSL_NO_VENDOR = 1;

  useFetchCargoVendor = true;
  cargoHash = "sha256-rOfJz5G6kO1/IM6M6dZJTJmzJhx/450dIPvAVBHUp5o=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  preBuild = ''
    export OPENSSL_DIR=${lib.getDev openssl}
    export OPENSSL_LIB_DIR=${lib.getLib openssl}/lib
  '';

  # The integration tests will start downloading docker image of DynamoDB, which
  # will naturally fail for nix build. The CLI tests do not need DynamoDB.
  cargoTestFlags = [ "cli_tests" ];

  meta = with lib; {
    description = "DynamoDB CLI written in Rust";
    mainProgram = "dy";
    homepage = "https://github.com/awslabs/dynein";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ pimeys ];
  };
}
