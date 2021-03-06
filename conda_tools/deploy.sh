version=18
ambertools_version=18
tarfile=amber$version.tar
platform=`python -c '
import sys
if sys.platform.startswith("darwin"):
    print("osx-64")
else: print("linux-64")
'`
prefix=tmp_${platform}_AT

cd $HOME
git clone https://github.com/$AT_GH_USER/$AT_GH_REPO_BINARY_DEV
git config --global user.email "$AT_GH_EMAIL" > /dev/null 2>&1
git config --global user.name "$AT_GH_USER" > /dev/null 2>&1
cp $HOME/ambertools-binary-build/conda_tools/amber.py27.sh $HOME/amber${version}/amber.sh

if [ "$TRAVIS" = "true" ]; then
    msg="travis build $TRAVIS_BUILD_NUMBER"
    mkdir amber${ambertools_version}
    cp -rf amber$version/{amber.sh,bin,lib,include,dat} amber${ambertools_version}/
    echo "date = `date`"
    echo `date` > amber${ambertools_version}/date.log
    cp $HOME/ambertools-binary-build/conda_tools/{amber.setup_test_folders,amber.run_tests} \
        amber${ambertools_version}/bin/
    tar -cf $tarfile amber${ambertools_version}/{date.log,amber.sh,bin,lib,include,dat}
    gzip $tarfile
fi

if [ "$CIRCLECI" = "true" ]; then
    msg="circle build $CIRCLE_BUILD_NUM, from $CIRCLE_BUILD_URL"
    cp $HOME/TMP/amber-conda-bld/non-conda-install/linux-64.*.tar.bz2 \
        $HOME/$tarfile.gz
fi

cd $AT_GH_REPO_BINARY_DEV
rm -rf .git
git init .
split -b 40000000 $HOME/$tarfile.gz $prefix
git add tmp*AT*
ls ${prefix}*

git commit -m "$msg"
git remote add production https://${AT_GH_TOKEN}@github.com/$AT_GH_USER/$AT_GH_REPO_BINARY_DEV > /dev/null
git push production master -f
