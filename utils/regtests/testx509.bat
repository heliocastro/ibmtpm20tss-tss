REM #############################################################################
REM #										#
REM #			TPM2 regression test					#
REM #			     Written by Ken Goldman				#
REM #		       IBM Thomas J. Watson Research Center			#
REM #										#
REM # (c) Copyright IBM Corporation 2018 - 2019					#
REM # 										#
REM # All rights reserved.							#
REM # 										#
REM # Redistribution and use in source and binary forms, with or without	#
REM # modification, are permitted provided that the following conditions are	#
REM # met:									#
REM # 										#
REM # Redistributions of source code must retain the above copyright notice,	#
REM # this list of conditions and the following disclaimer.			#
REM # 										#
REM # Redistributions in binary form must reproduce the above copyright		#
REM # notice, this list of conditions and the following disclaimer in the	#
REM # documentation and/or other materials provided with the distribution.	#
REM # 										#
REM # Neither the names of the IBM Corporation nor the names of its		#
REM # contributors may be used to endorse or promote products derived from	#
REM # this software without specific prior written permission.			#
REM # 										#
REM # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS	#
REM # "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT		#
REM # LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR	#
REM # A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT	#
REM # HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,	#
REM # SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT		#
REM # LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,	#
REM # DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY	#
REM # THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT	#
REM # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE	#
REM # OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.	#
REM #										#
REM #############################################################################

setlocal enableDelayedExpansion

echo ""
echo "TPM2_CertifyX509"
echo ""

rem # basic test

rem # sign%%Arpriv.bin is a restricted signing key
rem # sign%%Apriv.bin is an unrestricted signing key

for %%A in (rsa ecc) do (

    echo "Load the %%A issuer key 80000001 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Arpriv.bin -ipu sign%%Arpub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Load the %%A subject key 80000002 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Apriv.bin -ipu sign%%Apub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Self Certify CA Root %%A"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000001 -halg sha256 -pwdk sig -pwdo sig -opc tmppart1.bin -os tmpsig1.bin -oa tmpadd1.bin -otbs tmptbs1.bin -ocert tmpx5091.bin -salg %%A -sub -v -iob 00050472 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )


    rem # dumpasn1 -a -l -d     tmpx509i.bin > tmpx509i1.dump
    rem # dumpasn1 -a -l -d -hh tmpx509i.bin > tmpx509i1.dumphh
    rem # dumpasn1 -a -l -d     tmppart1.bin > tmppart1.dump
    rem # dumpasn1 -a -l -d -hh tmppart1.bin > tmppart1.dumphh
    rem # dumpasn1 -a -l -d     tmpadd1.bin  > tmpadd1.dump
    rem # dumpasn1 -a -l -d -hh tmpadd1.bin  > tmpadd1.dumphh
    rem # dumpasn1 -a -l -d     tmpx5091.bin > tmpx5091.dump
    rem # dumpasn1 -a -l -d -hh tmpx5091.bin > tmpx5091.dumphh
    rem # openssl x509 -text -inform der -in tmpx5091.bin -noout > tmpx5091.txt

    echo "Convert issuer X509 DER to PEM"
    openssl x509 -inform der -in tmpx5091.bin -out tmpx5091.pem

    echo "Verify %%A self signed issuer root" 
    openssl verify -CAfile tmpx5091.pem tmpx5091.pem

    echo "Signing Key Certify %%A"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -iob 00040472 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

rem     # dumpasn1 -a -l -d     tmpx509i.bin > tmpx509i2.dump
rem     # dumpasn1 -a -l -d -hh tmpx509i.bin > tmpx509i2.dumphh
rem     # dumpasn1 -a -l -d     tmppart2.bin > tmppart2.dump
rem     # dumpasn1 -a -l -d -hh tmppart2.bin > tmppart2.dumphhe 
rem     # dumpasn1 -a -l -d     tmpadd2.bin  > tmpadd2.dump
rem     # dumpasn1 -a -l -d -hh tmpadd2.bin  > tmpadd2.dumphh
rem     # dumpasn1 -a -l -d     tmpx5092.bin > tmpx5092.dump
rem     # dumpasn1 -a -l -d -hh tmpx5092.bin > tmpx5092.dumphh
rem     # openssl x509 -text -inform der -in tmpx5092.bin -noout > tmpx5092.txt

    echo "Convert subject X509 DER to PEM"
    openssl x509 -inform der -in tmpx5092.bin -out tmpx5092.pem

    echo "Verify %%A subject against issuer" 
    openssl verify -CAfile tmpx5091.pem tmpx5092.pem


    echo "Signing Key Certify %%A with bad OID"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -iob ffffffff > run.out
    IF !ERRORLEVEL! EQU 0 (
       exit /B 1
    )
rem # bad der, test bits for 250 bytes
rem # better to get size from tmppart2.bin

rem     # for bit in {0..2}
rem     # do
rem     # 	echo "Signing Key Certify %%A testing bit $bit"
rem     # 	%TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -bit $bit > run.out
    rem IF !ERRORLEVEL! NEQ 0 (
    rem 	exit /B 1
    rem )

    echo "Flush the root CA issuer signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000001 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Flush the subject signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000002 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

)

rem # bad extensions for key type

echo ""
echo "TPM2_CertifyX509 Key Usage Extension for fixedTPM signing key"
echo ""

for %%A in (rsa ecc) do (

    echo "Load the %%A issuer key 80000001 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Arpriv.bin -ipu sign%%Arpub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Load the %%A subject key 80000002 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Apriv.bin -ipu sign%%Apub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A digitalSignature"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,digitalSignature > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A nonRepudiation"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,nonRepudiation > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyEncipherment > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

   echo "Signing Key Certify %%A dataEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,dataEncipherment > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyAgreement"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyAgreement > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyCertSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyCertSign > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A cRLSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,cRLSign > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A encipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,encipherOnly > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A decipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,decipherOnly > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Flush the root CA issuer signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000001 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Flush the subject signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000002 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

)

echo ""
echo "TPM2_CertifyX509 Key Usage Extension for not fixedTPM signing key"
echo ""

for %%A in (rsa ecc) do (

    echo "Load the %%A issuer key 80000001 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Anfpriv.bin -ipu sign%%Anfpub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Load the %%A subject key 80000002 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Anfpriv.bin -ipu sign%%Anfpub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A digitalSignature"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,digitalSignature > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A nonRepudiation"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,nonRepudiation > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyEncipherment > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

   echo "Signing Key Certify %%A dataEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,dataEncipherment > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyAgreement"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyAgreement > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyCertSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyCertSign > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A cRLSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,cRLSign > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A encipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,encipherOnly > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A decipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sig -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,decipherOnly > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Flush the root CA issuer signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000001 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Flush the subject signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000002 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

)

echo ""
echo "TPM2_CertifyX509 Key Usage Extension for fixedTpm restricted encryption key"
echo ""

for %%A in (rsa ecc) do (

    echo "Load the %%A issuer key 80000001 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr sign%%Arpriv.bin -ipu sign%%Arpub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Load the %%A subject key 80000002 under the primary key"
    %TPM_EXE_PATH%load -hp 80000000 -ipr store%%Apriv.bin -ipu store%%Apub.bin -pwdp sto > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A digitalSignature"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,digitalSignature > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A nonRepudiation"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,nonRepudiation > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyEncipherment > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A dataEncipherment"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,dataEncipherment > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyAgreement"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyAgreement > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A keyCertSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,keyCertSign > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A cRLSign"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,cRLSign > run.out
    IF !ERRORLEVEL! EQU 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A encipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,encipherOnly > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Signing Key Certify %%A decipherOnly"
    %TPM_EXE_PATH%certifyx509 -hk 80000001 -ho 80000002 -halg sha256 -pwdk sig -pwdo sto -opc tmppart2.bin -os tmpsig2.bin -oa tmpadd2.bin -otbs tmptbs2.bin -ocert tmpx5092.bin -salg %%A -ku critical,decipherOnly > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Flush the root CA issuer signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000001 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

    echo "Flush the subject signing key"
    %TPM_EXE_PATH%flushcontext -ha 80000002 > run.out
    IF !ERRORLEVEL! NEQ 0 (
	exit /B 1
    )

)

rem # cleanup

rm tmppart1.bin
rm tmpadd1.bin
rm tmptbs1.bin
rm tmpsig1.bin
rm tmpx5091.bin
rm tmpx5091.pem
rm tmpx5092.pem
rm tmpx509i.bin
rm tmppart2.bin
rm tmpadd2.bin
rm tmptbs2.bin
rm tmpsig2.bin
rm tmpx5092.bin

exit /B 0
