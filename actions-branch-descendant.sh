head_sha=`git rev-parse HEAD`
master_sha=`git rev-parse origin/master`
develop_sha=`git rev-parse origin/develop`
test_sha=`git rev-parse origin/test`
current_sha=$head_sha

echo "HEAD SHA: $head_sha"
echo "Master SHA: $master_sha"
echo "Develop SHA: $develop_sha"
echo "Test SHA: $test_sha"
echo ""

echo "Ancestor SHA list going from HEAD -> master:"
echo "$current_sha"
while [ $current_sha != $master_sha ] && [ $current_sha != $test_sha ] && [ $current_sha != $develop_sha ]
do
    current_sha=`git cat-file -p $current_sha | awk 'NR > 1 {if(/^parent/){print $2; exit}}'`
    echo "$current_sha"
done

echo ""
if [ $current_sha == $master_sha ] 
then
    echo "Master branch is closest MST parent. PR good to go 👍"
    echo "::set-output name=valid::true"
    echo "::set-output name=closest-MST-parent::Master"
    echo "::set-output name=PR-string::Master branch is closest MST parent. PR good to go 👍"
    exit 0
fi
if [ $current_sha == $develop_sha ] 
then
    echo "Develop branch is closest MST parent."
    echo "::set-output name=closest-MST-parent::Develop"
elif [ $current_sha == $test_sha ]
then
    echo "Test branch is closest MST parent."
    echo "::set-output name=closest-MST-parent::Test"
fi
echo "Master branch should be the closest MST parent. PR not good to go 👎"
echo "::set-output name=valid::false"
echo "::set-output name=PR-string::Master branch should be the closest MST parent. PR not good to go 👎"
exit 1