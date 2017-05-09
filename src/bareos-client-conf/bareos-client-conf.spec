%define		rpmrelease %{nil}

Name:		bareos-client-conf
Version:	%{_version}
Release:	1%{?dist}
Summary:	Bareos client configuration files

Group:		Applications/File
License:	GPLv3
URL:		https://github.com/rear/rear-workshop-osbconf-2016
Source0:	https://build.opensuse.org/package/show/home:gdha/bareos-client-conf/bareos-client-conf.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-XXXXXX)

#BuildRequires:
Requires:	bareos-fd, bareos-bconsole

BuildArch:	noarch

%description
Bareos client configuration files used during the workshop of rear DR exercise
with Bareos and rear

%prep
%setup -q


%build


%install
%{__rm} -rf %{buildroot} %{name}.spec
mkdir -vp %{buildroot}/etc/bareos
cp -rv * %{buildroot}/etc/bareos/

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, bareos, bareos, 0755)
/etc/bareos/*

%post
cp -v /etc/bareos/bconsole.conf.install /etc/bareos/bconsole.conf
systemctl restart bareos-fd

