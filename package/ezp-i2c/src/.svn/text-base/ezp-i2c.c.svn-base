//test.c: demonstration program using the BQ gauge and i2c interface

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "ezp-i2c.h"

int seti2caddr(unsigned char addr)
{
	int retval;
	
	//ioctl to set slave address
	retval = ioctl(i2cfile,RT2880_I2C_SET_ADDR,addr);

	//if we fail, tell the user and return the error code
	if(retval  < 0) {
		printf("Could not set slave address\n");
		close(i2cfile);
		return retval;
	}
	
	//set our current address variable to the new address
	//this is necessary because the IOCTL_RDWR ioctl requires you to specify the address for each message
	//since this address might change (if we enter ROM mode on the BQ device), we need to keep track of
	//which one we are using.
	return retval;
}
int init_i2c()
{
	char filename[20];
	int retval;
	
	snprintf(filename, 19, "/dev/i2c");
	
	//open the file and store it to our variable
	i2cfile = open(filename, O_RDWR);
	
	//if we failed, inform the reader and return the handle value
	if( i2cfile < 0) {
		printf("Couldread not open i2c device file\n");
		retval = i2cfile;
		return retval;
	}
	return retval;
}
int read_i2c(unsigned long *buf)
{
	int retval;
	retval = ioctl(i2cfile,rt2880_i2c_read,buf);
	
	//if we fail, tell the user, close the file, and return the error code
	if( retval < 0)
	{
		printf("Could not read from I2C\n");
		close(i2cfile);
	}
	
	return retval;
	
}
int write_i2c(unsigned long *buf)
{
	int retval;
	retval = ioctl(i2cfile,rt2880_i2c_write,buf);
	
	//if we fail, tell the user, close the file, and return the error code
	if( retval < 0)
	{
		printf("Could not write to I2C\n");
		close(i2cfile);
	}
	
	return retval;
}
void print_usage() {
    printf("ezp-i2c [gauge|security] ...\n");
    printf("ezp-i2c gauge [voltage|host|client] ...\n");
    printf("ezp-i2c gauge host [booting|ready|sleep]\n");
    exit(0);
}
int main(int argc, char **argv) {
    if (argc < 2) {
        print_usage();
    }
	
	//Initialize the I2C interface
	init_i2c();
    
    if (!strcmp(argv[1], "gauge")) {
        unsigned char *buf_write=malloc(sizeof(unsigned char));
        unsigned char *buf_read=malloc(sizeof(unsigned char));
        seti2caddr(0x58);
        rt2880_i2c_write=RT2880_I2C_GAUGE_WRITE;
        rt2880_i2c_read=RT2880_I2C_GAUGE_READ;

        if (!strcmp(argv[2], "voltage")) {
            FILE *pFile;
            char output[10]={0};
            unsigned int voltage=0;
            buf_write[0]=1;
            buf_write[1]=0x01;
            write_i2c(buf_write);
            sleep(1);
            buf_read[0]=2;
            read_i2c(buf_read);

            printf("Data Read: %d %d\n",buf_read[1],buf_read[2]);
            voltage=buf_read[1]+buf_read[2]*256;
            pFile =  fopen("/tmp/gauge_voltage", "w");
            snprintf(output,10,"%d",voltage);
            fwrite(output, 1 , strlen(output), pFile);
            fclose(pFile);
        } else if (!strcmp(argv[2], "host")) {
            buf_write[0]=2;
            buf_write[1]=0x02;
            if (!strcmp(argv[3], "booting")) {
                buf_write[2]=0x01;
            } else if (!strcmp(argv[3], "ready")) {
                buf_write[2]=0x02;
            } else if (!strcmp(argv[3], "sleep")) {
                buf_write[2]=0x04;
            } else {
                print_usage();
            }
            write_i2c(buf_write);
        } else if (!strcmp(argv[2], "client")) {
            buf_write[0]=1;
            buf_write[1]=0x03;
            sleep(1);
            buf_read[0]=1;
            read_i2c(buf_read);
            printf("Data Read: %d \n",buf_read[1]);
        } else if (!strcmp(argv[2], "state")) {
            FILE *pFile;
            char output[10]={0};
            unsigned int state=0;
            buf_write[0]=1;
            buf_write[1]=0x04;
            write_i2c(buf_write);
            sleep(1);
            buf_read[0]=1;
            read_i2c(buf_read);

            printf("Data Read: %d\n",buf_read[1]);
            state=buf_read[1];
            pFile =  fopen("/tmp/gauge_state", "w");
            snprintf(output,10,"%d",state);
            fwrite(output, 1 , strlen(output), pFile);
            fclose(pFile);
        } else {
            print_usage();
        }
        free(buf_read);
        free(buf_write);
    } else if (!strcmp(argv[1], "security")) {
        unsigned char buf_rand[4]={0};
        unsigned char buf[4]={0};
        unsigned char buf_return[4]={0};
        int cnt=0;
        unsigned char flag=1;
        FILE *pFile;
        char output[1024]={0};
        seti2caddr(0x50);
        rt2880_i2c_write=RT2880_I2C_SECURITY_WRITE;
        rt2880_i2c_read=RT2880_I2C_SECURITY_READ;
        write_i2c(buf_rand);
        printf("Data rand: %02x%02x%02x%02x\n",buf_rand[0],buf_rand[1],buf_rand[2],buf_rand[3]);
        buf[0] = ((~buf_rand[0])^buf_rand[1]^(~buf_rand[2])^buf_rand[3])+key1;
        buf[1] = (buf_rand[0]^(~buf_rand[1])^buf_rand[2]^(~buf_rand[3]))+key2;
        buf[2] = ((~buf_rand[0])^buf_rand[1]^buf_rand[2]^buf_rand[3])+key3;
        buf[3] = (buf_rand[0]^buf_rand[1]^(~buf_rand[2])^buf_rand[3])+key4;
        printf("Data: %02x%02x%02x%02x\n",buf[0],buf[1],buf[2],buf[3]);
        sleep(1);	
        read_i2c(buf_return);
        printf("Data Read: %02x%02x%02x%02x\n",buf_return[0],buf_return[1],buf_return[2],buf_return[3]);
        for (cnt=0;cnt<4;cnt++) {
            if (buf[cnt] != buf_return[cnt]) flag=0;
        }
        if (flag) {
            system("nvram replace attr license_status_rule 0 state 1");
            system("nvram replace attr license_status_rule 0 trycount 0");
        } else {
            system("nvram replace attr license_status_rule 0 state 0");
        }
        pFile =  fopen("/tmp/ezp-i2c_security", "w");
        snprintf(output,1024,"Data rand: %02x%02x%02x%02x\n",buf_rand[0],buf_rand[1],buf_rand[2],buf_rand[3]);
        snprintf(output,1024,"%sData: %02x%02x%02x%02x\n",output,buf[0],buf[1],buf[2],buf[3]);
        snprintf(output,1024,"%sData Read: %02x%02x%02x%02x\n",output,buf_return[0],buf_return[1],buf_return[2],buf_return[3]);
        fwrite(output, 1 , strlen(output), pFile);
        fclose(pFile);
    } else {
        print_usage();
    }
	close(i2cfile);
	return 0;
}
