FROM mcr.microsoft.com/dotnet/core/sdk:3.1-bionic AS build-env

WORKDIR /app

# Install mongo driver
#RUN dotnet add BooksApi.csproj package MongoDB.Driver -v 2.9.1
# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic

# Installer le root-ca Lacave dans le truststore du conteneur
ADD cert/root-ca.crt /usr/local/share/ca-certificates/lacave-root-ca.crt
RUN update-ca-certificates

# Activer le debuggage
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://aka.ms/getvsdbgsh | \
       bash /dev/stdin -v latest -l /vsdbg
       
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "BooksApi.dll"]

