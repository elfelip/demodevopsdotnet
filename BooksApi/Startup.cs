﻿using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

using BooksApi.Models;
using BooksApi.Services;

namespace BooksApi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer("Bearer", options =>
            {
                options.Authority = Configuration["Keycloak:Issuer"];
                options.RequireHttpsMetadata = false;

                options.Audience = Configuration["Keycloak:ClientId"];
            });
            services.Configure<BookstoreDatabaseSettings>(
            Configuration.GetSection(nameof(BookstoreDatabaseSettings)));

            services.AddSingleton<IBookstoreDatabaseSettings>(sp =>
            sp.GetRequiredService<IOptions<BookstoreDatabaseSettings>>().Value);

            services.AddSingleton<BookService>();
            services.AddControllers();
            services.AddAuthorization(options => 
            {
                options.DefaultPolicy = new AuthorizationPolicyBuilder(JwtBearerDefaults.AuthenticationScheme)
                    .RequireAuthenticatedUser()
                    .Build();
                options.AddPolicy("customer",
                          policy => policy.RequireAssertion(context =>
                                  context.User.HasClaim(c =>
                                     c.Type == "client_roles" && 
                                     c.Value.Contains("customer"))));
                options.AddPolicy("employee",
                          policy => policy.RequireAssertion(context =>
                                  context.User.HasClaim(c =>
                                     c.Type == "client_roles" && 
                                     c.Value.Contains("employee"))));
                options.AddPolicy("admin",
                          policy => policy.RequireAssertion(context =>
                                  context.User.HasClaim(c =>
                                     c.Type == "client_roles" && 
                                     c.Value.Contains("admin"))));
                //options.AddPolicy("customer",
                //          policy => policy.RequireAssertion(context =>
                //                  context.User.HasClaim(c =>
                //                     c.Type == String.Format("resource_access.{0}.roles", Configuration["Keycloak:ClientId"]) && 
                //                     c.Value.Contains("customer"))));
                //options.AddPolicy("employee",
                //          policy => policy.RequireAssertion(context =>
                //                  context.User.HasClaim(c =>
                //                     c.Type == String.Format("resource_access.{0}.roles", Configuration["Keycloak:ClientId"]) && 
                //                     c.Value.Contains("employee"))));
                //options.AddPolicy("admin",
                //          policy => policy.RequireAssertion(context =>
                //                  context.User.HasClaim(c =>
                //                     c.Type == String.Format("resource_access.{0}.roles", Configuration["Keycloak:ClientId"]) && 
                //                     c.Value.Contains("admin"))));
            });
            
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseHttpsRedirection();
            
            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
