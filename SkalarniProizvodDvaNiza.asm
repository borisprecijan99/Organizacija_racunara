;Napisati program koji ucitava broj N i dva niza A i B
;sa po N elemenata u sistemu s osnovom 14 (najvise 20 elemenata po nizu)
;i nakon toga posebnom procedurom izracunava i ispisuje skalarni
;proizvod ta dva niza takodje u osnovi 14. (SP=A1*B1+A2*B2+...An*Bn)

;Definicija segmenta podataka
podaci segment
    n dw 0
    maxDuzinaNiza dw 20
    maxDuzinaBroja dw 6
    maxDuzinaBrojaSa$ dw 0
    stringElementDuzina dw 0  
    osnova dw 14
    jeOsnova14 dw 0
    skalarniProizvodNiz dw 12 dup(0)
    niz1 db 20 dup("000000$")
    niz2 db 20 dup("000000$")
    porukaKraj db "Press any key to continue . . .$"
    porukaDveTacke db ": $"
    porukaUnesiteN db "Unesite n: $"
    porukaNNePripadaIntervalu db "N koje ste uneli ne pripada intervalu [1, 20].$"
    porukaUnosElemenataNiza1 db "Unos elemenata niza 1$"
    porukaUnosElemenataNiza2 db "Unos elemenata niza 2$"
    porukaUnesiteElementNiza db "Unesite element niza na poziciji $"    
    stringN db "         "
    stringElement db "         "
    skalarniProizvodRezultat db "00000000000000$"
    porukaSkalarniProizvodRezultat db "Skalarni proizvod za unete nizove je $"
    elementNiz1 db "       "
    elementNiz2 db "       "
    stringPozicija db "   "
    brojElement1 db 0
    brojElement2 db 0
    kolicnik dw 0
    ostatak db 0       
podaci ends

;Definicija stek segmenta
stek segment stack
    dw 128 dup(0)
stek ends

;Makro za ucitavanje znaka bez prikaza i cuvanja     
ucitajZnak macro
    push ax
    mov ah, 08
    int 21h
    pop ax
endm

;Makro za stampanje stringa na ekran
;Kao parametar makroa se ocekuje ofsetna adresa stringa
;koji se stampa
stampajString macro string
    push ax
    push dx  
    mov dx, offset string
    mov ah, 09
    int 21h
    pop dx
    pop ax
endm

;Makro za stampanje stringa na ekran, ali bez nula sa leve strane
;Kao parametar makroa se ocekuje ofsetna adresa stringa
;koji se stampa
stampajStringBezNulaNaPocetku macro string
    push ax
    push si
    push dx
    local petlja
    local umanjiSIZa1
    local kraj
    mov si, offset string
    dec si
    petlja:
        inc si
        cmp [si], '0'
        je petlja
    cmp [si], '$'
    je umanjiSIZa1
    jne kraj
    umanjiSIZa1:
        dec si
    kraj:
        mov dx, si
        mov ah, 09
        int 21h
        pop dx
        pop si
        pop ax
endm

;Makro za prekid programa           
prekiniProgram macro
    mov ax, 4c02h
    int 21h
endm

;Makro koji izracunava duzinu stringa
;Parametri makroa su ofsetna adresa stringa i promenljiva
;u koju ce biti smestena izracunata duzina stringa
izracunajDuzinuStringa macro string, duzinaStringa
    push ax
    push dx 
    push cx
    push si              
    local duzina
    lea dx, string 
    mov si, dx
    mov cx, 0
    duzina:            
        mov al, [si] 
        add cx, 1  
        inc si 
        cmp al, '$' 
        jne duzina
    dec cx
    mov duzinaStringa, cx
    pop si  
    pop cx
    pop dx
    pop ax   
endm

;Makro koji proverava da li je znak cifra ili ne
;Makro od parametara ocekuje znak i rezultat u koji
;ce biti smesten rezultat izvrsavanja makroa
jeCifra macro znak, rezultat
    push ax
    local nijeCifra
    local kraj
    mov ah, znak
    cmp ah, '0'
    jnge nijeCifra
    cmp ah, '9'
    jnle nijeCifra
    mov rezultat, 1
    jmp kraj
    nijeCifra:
        mov rezultat, 0
    kraj:
        pop ax    
endm

;Makro koji proverava da li je znak A, B, C ili D
;Makro od parametara ocekuje znak i rezultat u koji
;ce biti smesten rezultat izvrsavanja makroa
jeVelikoABCIliD macro znak, rezultat
    push ax
    local nijeVelikoABCIliD
    local kraj
    mov ah, znak
    cmp ah, 'A'
    jnge nijeVelikoABCIliD
    cmp ah, 'D'
    jnle nijeVelikoABCIliD
    mov rezultat, 1
    jmp kraj
    nijeVelikoABCIliD:
        mov rezultat, 0
    kraj:
        pop ax    
endm

;Makro koji proverava da li je znak a, b, c ili d
;Makro od parametara ocekuje znak i rezultat u koji
;ce biti smesten rezultat izvrsavanja makroa
jeMaloABCIliD macro znak, rezultat
    push ax
    local nijeMaloABCIliD
    local kraj
    mov ah, znak
    cmp ah, 'a'
    jnge nijeMaloABCIliD
    cmp ah, 'd'
    jnle nijeMaloABCIliD
    mov rezultat, 1
    jmp kraj
    nijeMaloABCIliD:
        mov rezultat, 0
    kraj:
        pop ax    
endm

;Makro koji uneti znak u osnovi 14 pretvara
;u broj u osnovi 10
konvertujZnakOsnova14UBroj macro znak, rezultat
    push bx
    local cifra
    local maloABCIliD
    local velikoABCIliD
    local kraj
    
    jeCifra znak, bh
    cmp bh, 1
    je cifra
    
    jeVelikoABCIliD znak, bh
    cmp bh, 1
    je velikoABCIliD
    
    jeMaloABCIliD znak, bh
    cmp bh, 1
    je maloABCIliD
    
    cifra:
        mov bh, znak
        sub bh, 48
        mov rezultat, bh
        jmp kraj
                
    velikoABCIliD:
        mov bh, znak
        sub bh, 55
        mov rezultat, bh
        jmp kraj 
               
    maloABCIliD:
        mov bh, znak
        sub bh, 87
        mov rezultat, bh  
        
    kraj:
        pop bx    
endm

;Makro koji uneti broj u osnovi 10 pretvara
;u znak u osnovi 14
konvertujBrojUZnakOsnova14 macro broj, rezultat
    push bx
    local cifra
    local velikoABCIliD
    local kraj
    
    jeCifra broj, bh
    cmp bh, 1
    je cifra
    
    mov bl, broj
    add bl, 55
    jeVelikoABCIliD bl, bh
    cmp bh, 1
    je velikoABCIliD
    
    cifra:
        mov bh, broj
        add bh, 48
        mov rezultat, bh
        jmp kraj
        
    velikoABCIliD:
        mov bh, bl
        mov rezultat, bh
        
    kraj:
        pop bx    
endm

;Definicija kod segmenta
kod segment
    ;Procedura koja prebacuje kursor sa pozicije (x, y) na
    ;poziciju (0, y+1) tj. prebacuje ga na pocetak novog reda
    predjiUNoviRed proc
        push ax
        push bx
        push cx
        push dx
        mov ah, 03
        mov bh, 0
        int 10h
        inc dh
        mov dl, 0
        mov ah, 02
        int 10h
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    predjiUNoviRed endp
    
    ;Procedura koja ucitava string sa tastature
    ;Na steku se ocekuju duzina stringa i njegova ofsetna adresa
    ucitajString proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov bp, sp
        mov dx, [bp+12]
        mov bx, dx
        mov ax, [bp+14]
        mov byte [bx], al
        mov ah, 0ah
        int 21h
        mov si, dx     
        mov cl, [si+1] 
        mov ch, 0
        kopiraj:
            mov al, [si+2]
            mov [si], al
            inc si
            loop kopiraj     
        mov [si], '$'
        pop si  
        pop dx
        pop cx
        pop bx
        pop ax
        ret 4
    ucitajString endp 
    
    ;Procedura koja konvertuje string u integer
    ;Procedura na steku ocekuje ofsetnu adresu stringa
    ;i ofsetnu adresu integera
    konvertujStringUInteger proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov bp, sp
        mov bx, [bp+14]
        mov ax, 0
        mov cx, 0
        mov si, 10
        petlja1:
            mov cl, [bx]
            cmp cl, '$'
            je kraj1
            mul si
            sub cx, 48
            add ax, cx
            inc bx  
            jmp petlja1
        kraj1:
            mov bx, [bp+12] 
            mov [bx], ax 
            pop si  
            pop dx
            pop cx
            pop bx
            pop ax
            ret 4
    konvertujStringUInteger endp
    
    ;Procedura koja konvertuje integer u string
    ;Procedura na steku ocekuje integer i ofsetnu adresu stringa
    ;u koji ce biti smestena tekstualna reprezentacija broja
    konvertujIntegerUString proc
        push ax
        push bx
        push cx
        push dx
        push si
        mov bp, sp
        mov ax, [bp+14] 
        mov dl, '$'
        push dx
        mov si, 10
        petlja2:
            mov dx, 0
            div si
            add dx, 48
            push dx
            cmp ax, 0
            jne petlja2   
        mov bx, [bp+12]
        petlja2a:      
            pop dx
            mov [bx], dl
            inc bx
            cmp dl, '$'
            jne petlja2a
        pop si  
        pop dx
        pop cx
        pop bx
        pop ax 
        ret 4
    konvertujIntegerUString endp
    
    ;Procedura koja ucitava elemente niza
    ;Procedura na steku ocekuje ofsetnu adresu niza
    ucitajNiz proc
        push ax
        push bx
        push dx
        push si
        push di
        push bp
        mov bp, sp       
        mov si, [bp+14]
        
        mov dx, 0
        ;Unos n elemenata niza
        unos:
            ;Stampanje poruke da se unese element niza
            ;na poziciji dx
            call predjiUNoviRed
            stampajString porukaUnesiteElementNiza
            push dx
            push offset stringPozicija
            call konvertujIntegerUString
            stampajString stringPozicija
            stampajString porukaDveTacke
            
            ;Ucitavanje stringa sa tastature
            push maxDuzinaBrojaSa$
            lea ax, stringElement
            push ax
            call ucitajString
            
            ;Provera da li je uneti string broj
            ;u osnovi 14
            push jeOsnova14
            lea ax, stringElement
            push ax
            call proveriString
            pop jeOsnova14
            
            ;Ako broj nije u osnovi 14, ponovo se trazi
            ;od korisnika da ucita string sa tastature
            cmp jeOsnova14, 0
            je unos
            
            ;Racunanje duzine unetog stringa
            izracunajDuzinuStringa stringElement, stringElementDuzina
            inc stringElementDuzina
            
            ;Smestanje unetog elementa na odredjenu poziciju
            ;u nizu
            mov di, 0
            add bx, maxDuzinaBrojaSa$
            sub bx, stringElementDuzina
            petlja3:
                mov ah, stringElement[di]
                mov [si+bx], ah
                inc di
                inc bx
                cmp di, stringElementDuzina
                jl petlja3    
            inc dx            
            cmp dx, n
            jl unos
        pop bp
        pop di
        pop si
        pop dx
        pop bx
        pop ax
        ret 2        
    endp
    
    ;Procedura koja proverava da li je string u osnovi 14
    ;Procedura na steku ocekuje promenljivu za rezultat i
    ;string koji je potrebno proveriti
    proveriString proc
        push si
        push ax
        push bx
        push bp
        mov bp, sp
        mov si, [bp+10]
        petlja4:
            xor ax, ax
            jeCifra [si], bl
            or ax, bx 
            
            jeMaloABCIliD [si], bl
            or ax, bx
            
            jeVelikoABCIliD [si], bl
            or ax, bx
            
            cmp ax, 0
            je kraj2
             
            inc si
            cmp [si], '$'
            jne petlja4                
        kraj2:
            mov [bp+12], ax
            pop bp
            pop bx
            pop ax
            pop si
            ret 2    
    endp
    
    ;Procedura koja sadrzaj jednog stringa kopira u drugi string
    ;Procedura na steku ocekuje ofsetnu adresu stringa koji se
    ;kopira i ofsetnu adresu rezultujuceg stringa
    kopirajString proc
        push ax
        push cx
        push si
        push di
        push bp
        mov bp, sp
        mov si, [bp+14]
        mov di, [bp+12]
        mov cx, maxDuzinaBrojaSa$
        petlja5:
            mov ah, [si]
            mov [di], ah
            inc si
            inc di
            loop petlja5
        pop bp
        pop di
        pop si
        pop cx
        pop ax
        ret 4    
    endp
    
    ;Procedura koja racuna skalarni proizvod dva niza
    ;Procedura na steku ocekuje ofsetne adrese dva niza za
    ;koje je potrebno izracunati skalarni proizvod
    skalarniProizvod proc
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        mov bp, sp
        mov si, [bp+18]
        mov di, [bp+16]
        mov cx, n
        petlja6:
            ;Kopiranje sadrzaja stringa sa ofsetnom adresom si
            ;u string elementNiz1
            push si
            push offset elementNiz1
            call kopirajString
            ;Kopiranje sadrzaja stringa sa ofsetnom adresom di
            ;u string elementNiz2
            push di
            push offset elementNiz2
            call kopirajString
            ;Mnozenje i smestanje rezultata u niz
            ;skalarniProizvodNiz
            push si
            push di
            mov si, 0
            mov di, 0
            mov bx, 0
            petlja6a:
                mov si, 0
                mov bx, di
                petlja6b:                    
                    konvertujZnakOsnova14UBroj elementNiz1[si], brojElement1
                    konvertujZnakOsnova14UBroj elementNiz2[di], brojElement2
            
                    xor ax, ax
                    xor dx, dx
                    mov al, brojElement1
                    mov dl, brojElement2
                    mul dl
                    push di
                    mov di, 0
                    add di, si
                    add di, si
                    add di, bx
                    add di, bx
                    add di, 2
                    add skalarniProizvodNiz[di], ax
                    pop di
                    inc si
                    cmp si, maxDuzinaBroja
                    jl petlja6b
                inc di
                cmp di, maxDuzinaBroja
                jl petlja6a
            pop di
            pop si
            
            add si, maxDuzinaBrojaSa$
            add di, maxDuzinaBrojaSa$
            loop petlja6
        
        ;Dobijanje konacnog rezultata i smestanje u
        ;string skalarniProizvodRezultat
        mov cx, 12
        petlja7:        
            mov bx, cx
            dec bx
            mov si, bx
            shl si, 1
            mov di, bx
            add di, 2
            mov dx, 0
            mov ax, skalarniProizvodNiz[si]
            add ax, kolicnik
            mov bx, osnova
            div bx
            mov ostatak, dl
            mov kolicnik, ax            
            konvertujBrojUZnakOsnova14 ostatak, skalarniProizvodRezultat[di]
            loop petlja7
        
        mov cx, 2
        petlja8:
            mov si, cx
            dec si
            xor dx, dx
            mov ax, kolicnik
            mov bx, osnova
            div bx
            mov ostatak, dl
            mov kolicnik, ax
            konvertujBrojUZnakOsnova14 ostatak, skalarniProizvodRezultat[si]
            loop petlja8
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        ret 4
    endp
    
    ;Podesavanje segmentnih registara
    assume cs:kod, ss:stek
    start:                
        mov ax, podaci
        mov ds, ax
        
        ;Stampanje poruke za unos broja n tj. duzine niza
        stampajString porukaUnesiteN
        
        ;Ucitavanje stringa sa tastature i smestanje u
        ;promenljivu stringN i postavljanje vrednosti
        ;promenljivoj maxDuzinaBrojaSa$
        mov ax, maxDuzinaBroja
        inc ax
        mov maxDuzinaBrojaSa$, ax
        push maxDuzinaBrojaSa$
        push offset stringN
        call ucitajString
        
        ;Konvertovanje unetog stringa u integer                 
        push offset stringN
        push offset n
        call konvertujStringUInteger
        
        ;Provera da li n pripada intervalu [1, maxDuzinaNiza]
        mov ax, maxDuzinaNiza
        
        ;Ako je n manje od 1 ili vece od maxDuzinaNiza,
        ;program se zavrsava jer je dozvoljeno uneti samo
        ;brojeve koji pripadaju intervalu [1, maxDuzinaNiza]
        cmp n, 1
        jl nNePripadaIntervalu
        
        cmp n, ax
        jg nNePripadaIntervalu
        
        ;Unos elemenata prvog niza        
        call predjiUNoviRed
        call predjiUNoviRed                 
        stampajString porukaUnosElemenataNiza1
        lea ax, niz1
        push ax
        call ucitajNiz
        
        ;Unos elemenata drugog niza
        call predjiUNoviRed
        call predjiUNoviRed
        stampajString porukaUnosElemenataNiza2
        lea ax, niz2
        push ax
        call ucitajNiz
        
        ;Poziv procedure koja racuna skalarni proizvod
        ;za niz1 i niz2
        lea ax, niz1
        push ax
        lea ax, niz2
        push ax
        call skalarniProizvod
        
        ;Stampanje rezultata bez nula na pocetku
        call predjiUNoviRed
        call predjiUNoviRed
        stampajString porukaSkalarniProizvodRezultat
        stampajStringBezNulaNaPocetku skalarniProizvodRezultat
        
        jmp krajPrograma
        
        ;Labela na koju se skace ako n ne pripada intervalu
        ;[1, maxDuzinaNiza]    
        nNePripadaIntervalu:
            call predjiUNoviRed
            stampajString porukaNNePripadaIntervalu
        
        ;Labela na koju se skace kad se program zavrsava
        krajPrograma:
            call predjiUNoviRed
            stampajString porukaKraj
            ucitajZnak
            prekiniProgram        
kod ends
end start