head_sha=`git rev-parse HEAD`
main_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/main") <(git rev-list --first-parent "HEAD") | head -1`
develop_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/develop") <(git rev-list --first-parent "HEAD") | head -1`
test_sha=`diff --old-line-format='' --new-line-format='' <(git rev-list --first-parent "origin/test") <(git rev-list --first-parent "HEAD") | head -1`

echo "HEAD SHA: $head_sha"
echo "Main Fork SHA: $main_sha"
echo "Develop Fork SHA: $develop_sha"
echo "Test Fork SHA: $test_sha"
echo ""

if [ ! -z "$main_sha" ] && [ -z "$develop_sha" ] && [ -z "$test_sha" ]
then
    echo "Main branch is closest MST parent. PR good to go 👍"
    echo "::set-output name=valid::true"
    echo "::set-output name=closest-MST-parent::Main"
    echo "::set-output name=PR-string::Main branch is closest MST parent. PR good to go 👍"
    exit 0
fi

if [ ! -z "$develop_sha" ] && [ -z "$main_sha" ] && [ -z "$test_sha" ]
then
    echo "Develop branch is closest MST parent."
    echo "::set-output name=closest-MST-parent::Develop"
    echo "Main branch should be the closest MST parent. PR not good to go 👎"
    echo "::set-output name=valid::false"
    echo "::set-output name=PR-string::Main branch should be the closest MST parent. PR not good to go 👎"
    exit 1
fi

if [ ! -z "$test_sha" ] && [ -z "$main_sha" ] && [ -z "$develop_sha" ]
then
    echo "Test branch is closest MST parent."
    echo "::set-output name=closest-MST-parent::Test"
    echo "Main branch should be the closest MST parent. PR not good to go 👎"
    echo "::set-output name=valid::false"
    echo "::set-output name=PR-string::Main branch should be the closest MST parent. PR not good to go 👎"
    exit 1
fi

: ${main_sha:="0"}
: ${develop_sha:="0"}
: ${test_sha:="0"}

queue=($head_sha)
current_sha=${queue[0]}

echo "Ancestor SHA list going from HEAD -> main:"
echo "$current_sha"

while [ $current_sha != $main_sha ] && [ $current_sha != $test_sha ] && [ $current_sha != $develop_sha ]
do
    
    queue+=(`git log --pretty=%P -n 1 "$current_sha"`)
    queue=("${queue[@]:1}")
    current_sha=${queue[0]}
    echo "$current_sha"
done

echo ""
if [ $current_sha == $main_sha ] 
then
    echo "Main branch is closest MST parent. PR good to go 👍"
    echo "::set-output name=valid::true"
    echo "::set-output name=closest-MST-parent::Main"
    echo "::set-output name=PR-string::Main branch is closest MST parent. PR good to go 👍"
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
echo "Main branch should be the closest MST parent. PR not good to go 👎"
echo "::set-output name=valid::false"
echo "::set-output name=PR-string::Main branch should be the closest MST parent. PR not good to go 👎"
exit 1
