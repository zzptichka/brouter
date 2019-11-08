#!/bin/bash

JAVA='java -Xmx2600m -Xms2600m -Xmn32m'
BROUTER_PROFILES=$(realpath "../../profiles2")
SRTM_PATH=$(realpath "srtm")

BROUTER_JAR=$(realpath $(ls ../../../brouter-server/target/brouter-server-*-jar-with-dependencies.jar))
OSMOSIS_JAR=$(realpath "../../pbfparser/osmosis.jar")
PROTOBUF_JAR=$(realpath "../../pbfparser/protobuf.jar")
PBFPARSER_JAR=$(realpath "../../pbfparser/pbfparser.jar")
PLANET_FILE=${PLANET_FILE:-$(realpath "./canada-latest.osm.pbf")}

set -e
rm -rf tmp

mkdir tmp
cd tmp
mkdir nodetiles
mkdir waytiles
mkdir waytiles55
mkdir nodes55

${JAVA} -cp "${OSMOSIS_JAR}:${PROTOBUF_JAR}:${PBFPARSER_JAR}:${BROUTER_JAR}" -Ddeletetmpfiles=true -DuseDenseMaps=true  btools.util.StackSampler btools.mapcreator.OsmFastCutter ${BROUTER_PROFILES}/lookups.dat nodetiles waytiles nodes55 waytiles55  bordernids.dat  relations.dat  restrictions.dat  ${BROUTER_PROFILES}/all.brf ${BROUTER_PROFILES}/trekking.brf ${BROUTER_PROFILES}/softaccess.brf ${PLANET_FILE}

mkdir unodes55
${JAVA} -cp "${OSMOSIS_JAR}:${PROTOBUF_JAR}:${PBFPARSER_JAR}:${BROUTER_JAR}" -Ddeletetmpfiles=true -DuseDenseMaps=true btools.util.StackSampler btools.mapcreator.PosUnifier nodes55 unodes55 bordernids.dat bordernodes.dat ${SRTM_PATH}

mkdir segments
${JAVA} -cp "${OSMOSIS_JAR}:${PROTOBUF_JAR}:${PBFPARSER_JAR}:${BROUTER_JAR}" -DuseDenseMaps=true -DskipEncodingCheck=true btools.util.StackSampler btools.mapcreator.WayLinker unodes55 waytiles55 bordernodes.dat restrictions.dat ${BROUTER_PROFILES}/lookups.dat ${BROUTER_PROFILES}/all.brf segments rd5

cd ..

rm -rf ../../segments4
mv tmp/segments ../../segments4
rm -rf tmp
