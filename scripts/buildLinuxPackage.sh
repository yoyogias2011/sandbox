#!/bin/bash
app_path=$1
output_path=$2
sandbox_version=$3
sandbox_sha=$4

run_script=$app_path/scripts/linuxEmbeddedRun.sh
package_path=$output_path/sandbox

if [ -z "$2" ]; then
	echo "Arguments are: <git root> <output dir>"
	exit 1
fi

set -e

echo "downloading Gradle"
(cd /tmp/; wget https://downloads.gradle.org/distributions/gradle-2.12-bin.zip)
(cd /tmp/; unzip -q gradle-2.12-bin.zip)
export GRADLE_HOME="/tmp/gradle-2.12/bin"

# build jar
(cd $app_path/; $GRADLE_HOME/gradle clean build shadowJar bintrayUpload -Dsandbox_version="$sandbox_version")

# package it up
echo "Creating runnable package: $package_path"
printf "#!/bin/bash\nSANDBOX_VERSION='$sandbox_version-$sandbox_sha'\n" > $output_path/version
cat $output_path/version $run_script $app_path/build/libs/*-all.jar > $package_path && chmod +x $package_path
(cd $output_path; tar -cf sandbox.tar sandbox)
