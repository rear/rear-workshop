%define		rpmrelease %{nil}

Name:		bareos-client-conf	
Version:	1.0
Release:	1%{?dist}
Summary:	Bareos client configuration files	

Group:		Applications/File
License:	GPLv3
URL:		https://github.com/rear/rear-workshop-osbconf-2016
Source0:	https://build.opensuse.org/package/show/home:gdha/bareos-client-conf/bareos-client-conf.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-XXXXXX)

#BuildRequires:
Requires:	bareos-fd

%description
Bareos client configuration files used during the workshop of rear DR exercise
with Bareos and rear

%prep
%setup -q


%build


%install
%{__rm} -rf %{buildroot}
mkdir -vp %{buildroot}/etc/bareos
# copy the config files
cp -rv * %{buildroot}/etc/bareos/
rm -f %{buildroot}/etc/bareos/%{name}.spec

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, bareos, bareos, 0755)
/etc/bareos/


%changelog
* Mon May 31 2016 Gratien D'haese ( gratien.dhaese at gmail.com ) 1.0-1
- Initial package
