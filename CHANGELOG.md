# Changelog

## [0.16.0](https://github.com/ATIX-AG/fog-proxmox/compare/v0.15.1...v0.16.0) (2025-07-10)


### Features

* :sparkles: add bios attribute in server config ([07c50b8](https://github.com/ATIX-AG/fog-proxmox/commit/07c50b8a213d5079ad657b38cd69b02f6bc66fcf))
* :sparkles: add cpu flatten ([a3483b7](https://github.com/ATIX-AG/fog-proxmox/commit/a3483b7ac618aaa86e282ce89dd630c325675c52))
* :sparkles: add mac compute ([85adc85](https://github.com/ATIX-AG/fog-proxmox/commit/85adc855c574010a6192155bf59bf3f761574243))
* :sparkles: add tokens user ([37aed80](https://github.com/ATIX-AG/fog-proxmox/commit/37aed80e5630b4916a93cbb49613a920a734182b)), closes [#66](https://github.com/ATIX-AG/fog-proxmox/issues/66)
* :sparkles: add volume template ([31d47ce](https://github.com/ATIX-AG/fog-proxmox/commit/31d47ce36b41a3bafd56c22369ce634432d8a0f5))
* :sparkles: fixes Add missing Meltdown / Spectre related CPU flags [#69](https://github.com/ATIX-AG/fog-proxmox/issues/69) ([d57cb3e](https://github.com/ATIX-AG/fog-proxmox/commit/d57cb3edadcd6833eeed4923ea7e6eceefb3196e))
* :sparkles: memory unit is Mb and disk size is Gb ([c5410b5](https://github.com/ATIX-AG/fog-proxmox/commit/c5410b5c79ed59a89bb4f0f2188613cbcc6a8f11))
* **container:** add gateway interface ([d7ec746](https://github.com/ATIX-AG/fog-proxmox/commit/d7ec746abe73a4f3165f189ada5b3159afa0dc13))
* **disk:** add human bytes ([1e649dd](https://github.com/ATIX-AG/fog-proxmox/commit/1e649ddf01e7ce9580db3fccbe723bea83fccde6))
* fixes [#61](https://github.com/ATIX-AG/fog-proxmox/issues/61) ([ef2c059](https://github.com/ATIX-AG/fog-proxmox/commit/ef2c059546536c7e9bc134d97ec86e33b1759298))
* **ip:** add ipv6 ([ca81042](https://github.com/ATIX-AG/fog-proxmox/commit/ca81042a6acaf56323dc921ef61a53d130310a82))
* **nic:** add ipv4 helpers CIDR check ([bc96ffe](https://github.com/ATIX-AG/fog-proxmox/commit/bc96ffe4f0e062976a489396a00ab3ba65d8eb5c))
* proxmox 6 suitable [#52](https://github.com/ATIX-AG/fog-proxmox/issues/52) ([dd4f54a](https://github.com/ATIX-AG/fog-proxmox/commit/dd4f54abeca53c87f23a120800d2783f85500b00))
* rename balloon memory ([597fd93](https://github.com/ATIX-AG/fog-proxmox/commit/597fd93f9a2c89f79b59fcce5892ddf271b9cb00))
* renew password [#49](https://github.com/ATIX-AG/fog-proxmox/issues/49) ([f2a9878](https://github.com/ATIX-AG/fog-proxmox/commit/f2a9878a1676348477c2ef45dcab773022f15a45))
* task exception ([e648f8e](https://github.com/ATIX-AG/fog-proxmox/commit/e648f8e2e06707ea204cc768b3ae572f33c104ab))


### Bug Fixes

* :bug: fixes renewal user token too ([04b6203](https://github.com/ATIX-AG/fog-proxmox/commit/04b6203d3bc86af640e3530727ab5c06183b4c11))
* :bug: fixes token credentials build ([ecb957c](https://github.com/ATIX-AG/fog-proxmox/commit/ecb957c375b5c6d8bc5cab3ffb92efc53218de7a))
* [#49](https://github.com/ATIX-AG/fog-proxmox/issues/49) ([98135a7](https://github.com/ATIX-AG/fog-proxmox/commit/98135a70da8977719a3d0e4b8e6cdd52ca0d0dff))
* [#50](https://github.com/ATIX-AG/fog-proxmox/issues/50) ([2c78d0c](https://github.com/ATIX-AG/fog-proxmox/commit/2c78d0cb7639efdd9267fc797594c9c6d9a3ffb5))
* 37: List servers by node only ([e76d213](https://github.com/ATIX-AG/fog-proxmox/commit/e76d213f7af6c9497ee980be63d756f25a359344))
* 45: add proxmox 5.3 compatibility ([2e8be02](https://github.com/ATIX-AG/fog-proxmox/commit/2e8be02892e8a776e33b48f130f097ffc2f0da4a))
* **controller:** fix extract value with column ([d61bf1b](https://github.com/ATIX-AG/fog-proxmox/commit/d61bf1b6bed8b513db6a01b587ebb6f494c9f2b3))
* cpu helper ([61964e8](https://github.com/ATIX-AG/fog-proxmox/commit/61964e80b9d410e59535547178b974c398853963))
* fixes [#62](https://github.com/ATIX-AG/fog-proxmox/issues/62) cpu type ([48ce28e](https://github.com/ATIX-AG/fog-proxmox/commit/48ce28e3f4a62ea202c0dd511e026e502133a084))
* Fixes EOF OpenSSL error in Proxmox connection ([#102](https://github.com/ATIX-AG/fog-proxmox/issues/102)) ([ac8b0e1](https://github.com/ATIX-AG/fog-proxmox/commit/ac8b0e11a39da6b19703b4f4507edf19486899ba))
* min ruby version to 2.5 ([6178945](https://github.com/ATIX-AG/fog-proxmox/commit/6178945830d2232590ffae747b014e8fe66c81ef))
* renew ticket ([cdcc78f](https://github.com/ATIX-AG/fog-proxmox/commit/cdcc78f21394d4c4ac309a278019e3f8a504a8d9))
* server migrate ([3ea2e02](https://github.com/ATIX-AG/fog-proxmox/commit/3ea2e029132b15cded1aa6bd971dd3a888ef8a17))

## [0.15.1](https://github.com/fog/fog-proxmox/compare/v0.15.0...v0.15.1) (2025-02-25)


### Bug Fixes

* Fixes EOF OpenSSL error in Proxmox connection ([#102](https://github.com/fog/fog-proxmox/issues/102)) ([ac8b0e1](https://github.com/fog/fog-proxmox/commit/ac8b0e11a39da6b19703b4f4507edf19486899ba))

## [0.15.0](https://github.com/fog/fog-proxmox/compare/v0.14.0...v0.15.0) (2022-12-01)


### Features

* :sparkles: memory unit is Mb and disk size is Gb ([c5410b5](https://github.com/fog/fog-proxmox/commit/c5410b5c79ed59a89bb4f0f2188613cbcc6a8f11))
