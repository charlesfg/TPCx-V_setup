yum clean all
rm -rf /var/cache/yum
rm -rf /var/tmp/yum-*
package-cleanup --quiet --leaves --exclude-bin | xargs yum remove -y
