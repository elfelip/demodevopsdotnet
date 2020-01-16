FROM mcr.microsoft.com/dotnet/core/sdk:2.2-bionic AS build-env
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
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-bionic
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "BooksApi.dll"]

