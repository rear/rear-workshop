%define		rpmrelease %{nil}

Name:		rear-workshop
Version:	1.0
Release:	1%{?dist}
Summary:	Rear configuration files	

Group:		Applications/File
License:	GPLv3
URL:		https://github.com/rear/rear-workshop
Source0:	https://build.opensuse.org/package/show/home:gdha/rear-workshop/rear-workshop.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-XXXXXX)

#BuildRequires:
Requires:	rear
BuildArch:	noarch

%description
Rear configuration files used during the REAR workshop as lab exercises

%prep
%setup -q


%build


%install
%{__rm} -rf %{buildroot}
mkdir -vp %{buildroot}/etc/rear/workshop
cp -rv *.conf %{buildroot}/etc/rear/workshop/
cp -v .cifs   %{buildroot}/etc/rear/workshop/
cp -v  README %{buildroot}/etc/rear/workshop/

%clean
%{__rm} -rf %{buildroot}

# Use the dir directive as /etc/rear is owned by package rear and not by rear-workshop
%files
%defattr(-, root, root, 0755)
%dir /etc/rear
/etc/rear/workshop


%changelog
* Wed Jul 06 2016 Gratien D'haese ( gratien.dhaese at gmail.com ) 1.0-1
- Initial package
