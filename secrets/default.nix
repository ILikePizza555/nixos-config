rec {
    publicHostKeys = {
        "nev-systems-nixos" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi2s5rq+44uhUaK4LhEYVDFmuCR4AroO05fOT0oIvB6";
        "r196-club" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQt5EZECRV00BWEONC6trjF5Ro1uAUCEZssxq/iyXeH";
    };

    secrets = {
        "nev-systems-nixos" = [
            ./namecheapapi-nev-systems.age
        ];

        "r196-club" = [
            ./namecheapapi-r196-club.age
        ]
    };
}