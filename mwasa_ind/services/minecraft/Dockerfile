FROM eclipse-temurin:17-jre-focal

WORKDIR /minecraft

COPY . .

ARG PAPER_DOWNLOAD=https://api.papermc.io/v2/projects/paper/versions/1.19.4/builds/527/downloads/paper-1.19.4-527.jar
ADD ${PAPER_DOWNLOAD} ./paper.jar

EXPOSE 25565

ARG MINECRAFT_MEMORY=2G

CMD java -Xms${MINECRAFT_MEMORY} -Xmx${MINECRAFT_MEMORY} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar ./paper.jar --nogui
