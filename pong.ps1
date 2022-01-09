Add-Type -Path '.\engine.dll'

$engine = New-Object engine.Functions 

# you can run $engine | Get-Member to help with intelissense in vscode

# make your code here :]

$quadrado = [engine.Rectangle2D]::GetNew(0,0,10,10,200,0,0,254)

$raqueteDireita = [engine.Rectangle2D]::GetNew(380,150,20,50,0,254,0,254)

$raqueteEsquerda = [engine.Rectangle2D]::GetNew(0,150, 20,50,0,0,254,254)

$engine.EnableAudioDevice()

[Raylib_cs.Sound]$somRaquete = $engine.LoadSoundFromFile("assets\sounds\sfxRaquete.wav")
[Raylib_cs.Sound]$somTeto = $engine.LoadSoundFromFile("assets\sounds\sfxTetoCHao.wav")
#$somRaquete = $engine.LoadSoundFromFile(".\sfxRaquete.wav")

$w = 400
$h = 300

$teto = [engine.Rectangle2D]::GetNew(0,-5,$w,5,0,0,0,254)
$chao = [engine.Rectangle2D]::GetNew(0,$h,$w,5,0,0,0,254)

$engine.CreateWindow($w,$h,"Pong");

$pontos = @{
	esquerda = 0
	direita = 0
}
$velBola = @{
	x = 0
	y = 0
	multiplicador = 1
}
function ZerarBola { param($vel)

	$quadrado.PosX = $w/2
	$quadrado.PosY = $h/2
	$velBola.multiplicador = 1

	$vel.x = ((-1,1) | Get-Random)*5
	$vel.y = 0
}
function PrintarFirulas {param ($txt, [engine.Rectangle2D]$retangulo)
	Write-Host $txt ' x ' $retangulo.PosX ' y ' $retangulo.PosY ' w ' $retangulo.largura ' h ' $retangulo.altura
}

function CrescerQuadrado { param ( $tam)
	$largura = $quadrado.largura
	$altura = $quadrado.altura
	$aMax = $retangulo.altura * $tam
	$lMax = $quadrado.largura * $tam
	while ($quadrado.largura -le $lMax -and $retangulo.altura -le $aMax) {
		Start-Sleep -Milliseconds 10
		$quadrado.largura++
		$quadrado.altura++
	}
	$quadrado.altura = $altura
	$quadrado.largura = $largura
}

ZerarBola -vel $velBola 

while(!$engine.IsAskingToCloseWindow())
{
	


	$quadrado.Move($velBola.x,$velBola.y)

	$txtPontos = [string]$pontos.esquerda + ' x ' + [string]$pontos.direita

	if($quadrado.IsCollidingWithRectangle2D($raqueteDireita))
	{
		$velBola.x = -(5 + ($velBola.multiplicador * 0.1))
		if($velBola.y -eq 0){
			$velBola.y = ((-1,1)|Get-Random) * 5
		}
		$velBola.multiplicador++
		$engine.PlayThisSound($somRaquete)
	}
	elseif($quadrado.IsCollidingWithRectangle2D($raqueteEsquerda))
	{
		$velBola.x = 5 + ($velBola.multiplicador * 0.1)
		if($velBola.y -eq 0){
			$velBola.y = ((-1,1)|Get-Random) * 5
		}
		$velBola.multiplicador++
		$engine.PlayThisSound($somRaquete)

		#Write-Host $velBola.multiplicador
		
	}elseif($quadrado.IsCollidingWithRectangle2D($teto))
	{
		$velBola.y = -$velBola.y 
		
		$velBola.multiplicador++
		$engine.PlayThisSound($somTeto)
		#Write-Host $velBola.multiplicador
		
	}elseif($quadrado.IsCollidingWithRectangle2D($chao))
	{
		$velBola.y = -$velBola.y 
		$velBola.multiplicador++
		$engine.PlayThisSound($somTeto)
		#Write-Host $velBola.multiplicador
	}
	
	if($engine.SegurandoCima())
	{
		$raqueteDireita.Move(0,-5)
	}elseif($engine.SegurandoBaixo())
	{
		$raqueteDireita.Move(0,5)

	}
	else { $raqueteDireita.Move(0,0) }

	if($engine.ApertouEspaco())
	{
		$quadrado.largura++
		$quadrado.altura++
	}
	

	if($engine.SegurandoW())
	{
		$raqueteEsquerda.Move(0,-5)
	}elseif ($engine.SegurandoS()) {
		$raqueteEsquerda.Move(0,5)

	}
	else { $raqueteEsquerda.Move(0,0) }

	if($quadrado.PosX + $quadrado.largura -ge $w)
	{
		ZerarBola -vel $velBola 
		$pontos.esquerda++
	}
	elseif($quadrado.PosX  -le 0)
	{
		ZerarBola -vel $velBola 
		$pontos.direita++

	}

	$engine.DrawTextCenter($txtPontos,20)

    $engine.DrawFrame();

	$teto.Draw()
	$chao.Draw()

	$quadrado.Draw()
    $raqueteDireita.Draw();
    $raqueteEsquerda.Draw();

    $engine.ClearFrameBackground();
    $engine.ClearFrame();

	Start-Sleep -Milliseconds 16
	
}

$engine.CloseWindow();