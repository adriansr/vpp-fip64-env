#!/bin/bash -xe


MDTS=adrian

pushd containers
for NAME in *
do
	pushd $NAME
	CONTAINER="mnsandbox${MDTS}_${NAME}_1"
	for FILE in $(find . -type f)
	do
		echo "Copy[$NAME] $FILE"
		docker cp $FILE $CONTAINER:$FILE
	done
	popd
done
popd

docker exec mnsandbox${MDTS}_midolman1_1 chmod +x run.sh
MAC=$(docker exec mnsandbox${MDTS}_midolman1_1 ./run.sh | grep '^MAC=' | cut -d= -f2)
test ! -z "${MAC?}"

docker exec mnsandbox${MDTS}_neutron_1 chmod +x run.sh
docker exec mnsandbox${MDTS}_neutron_1 ./run.sh $MAC

docker exec mnsandbox${MDTS}_quagga1_1 chmod +x run.sh
docker exec mnsandbox${MDTS}_quagga1_1 ./run.sh

