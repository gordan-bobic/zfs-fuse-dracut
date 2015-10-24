Name:		zfs-fuse-dracut
Version:        0.7.2
Release:        1
License:        GPL
URL:		https://github.com/gordan-bobic/zfs-fuse-dracut
Summary:        Dracut module for zfs-fuse
Group:          System Environment/Base
Source0:        %{name}-%{version}.tar.gz
Requires:	dracut zfs-fuse


%description
Dracut modules for using rootfs on zfs-fuse

%prep
%setup -q

%build
# Nothing to build

%install
mkdir -p %{buildroot}%{_libdir}/dracut/modules.d
mkdir -p %{buildroot}%{_libdir}/systemd/system
cp -a 99zfs %{buildroot}%{_libdir}/dracut/modules.d/

%files
%defattr(-,root,root)
%{_libdir}/dracut/modules.d/90zfs/*


%changelog
* Fri Oct 23 2015 Gordan Bobic <gordan@redsleeve.org> - 0.7.2-1
- Initial release
