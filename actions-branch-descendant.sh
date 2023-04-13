head_sha=`git rev-parse HEAD`
master_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/master") <(git rev-list --first-parent "HEAD") | head -1`
develop_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/develop") <(git rev-list --first-parent "HEAD") | head -1`
test_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/test") <(git rev-list --first-parent "HEAD") | head -1`

echo "HEAD SHA: $head_sha"
echo "Master Fork SHA: $master_sha"
echo "Develop Fork SHA: $develop_sha"
echo "Test Fork SHA: $test_sha"
echo ""

if [ ! -z "$master_sha" ] && [ -z "$develop_sha" ] && [ -z "$test_sha" ]
then
    echo "Master branch is closest MST parent. PR good to go 👍"
    echo "valid=true" >> $GITHUB_OUTPUT
    echo "closest-MST-parent=Master" >> $GITHUB_OUTPUT
    echo "PR-string=Master branch is closest MST parent. PR good to go 👍" >> $GITHUB_OUTPUT
    exit 0
fi

if [ ! -z "$develop_sha" ] && [ -z "$master_sha" ] && [ -z "$test_sha" ]
then
    echo "Develop branch is closest MST parent."
    echo "closest-MST-parent=Develop" >> $GITHUB_OUTPUT
    echo "Master branch should be the closest MST parent. PR not good to go 👎"
    echo "valid=false" >> $GITHUB_OUTPUT
    echo "PR-string=Master branch should be the closest MST parent. PR not good to go 👎" >> $GITHUB_OUTPUT
    exit 1
fi

if [ ! -z "$test_sha" ] && [ -z "$master_sha" ] && [ -z "$develop_sha" ]
then
    echo "Test branch is closest MST parent."
    echo "closest-MST-parent=Test" >> $GITHUB_OUTPUT
    echo "Master branch should be the closest MST parent. PR not good to go 👎"
    echo "valid=false" >> $GITHUB_OUTPUT
    echo "PR-string=Master branch should be the closest MST parent. PR not good to go 👎" >> $GITHUB_OUTPUT
    exit 1
fi

: ${master_sha:="0"}
: ${develop_sha:="0"}
: ${test_sha:="0"}

queue=($head_sha)
current_sha=${queue[0]}

echo "Ancestor SHA list going from HEAD -> master:"
echo "$current_sha"

while [ $current_sha != $master_sha ] && [ $current_sha != $test_sha ] && [ $current_sha != $develop_sha ]
do
    
    queue+=(`git log --pretty=%P -n 1 "$current_sha"`)
    queue=("${queue[@]:1}")
    current_sha=${queue[0]}
    echo "$current_sha"
done

echo ""
if [ $current_sha == $master_sha ] 
then
    echo "Master branch is closest MST parent. PR good to go 👍"
    echo "valid=true" >> $GITHUB_OUTPUT
    echo "closest-MST-parent=Master" >> $GITHUB_OUTPUT
    echo "PR-string=Master branch is closest MST parent. PR good to go 👍" >> $GITHUB_OUTPUT
    exit 0
fi
if [ $current_sha == $develop_sha ] 
then
    echo "Develop branch is closest MST parent."
    echo "closest-MST-parent=Develop" >> $GITHUB_OUTPUT
elif [ $current_sha == $test_sha ]
then
    echo "Test branch is closest MST parent."
    echo "closest-MST-parent=Test" >> $GITHUB_OUTPUT
fi
echo "Master branch should be the closest MST parent. PR not good to go 👎"
echo "valid=false" >> $GITHUB_OUTPUT
echo "PR-string=Master branch should be the closest MST parent. PR not good to go 👎" >> $GITHUB_OUTPUT
exit 1