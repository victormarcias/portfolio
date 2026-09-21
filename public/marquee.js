document.getElementById('year').textContent = new Date().getFullYear();

document.querySelector('.avatar').addEventListener('error', function () {
  this.replaceWith(Object.assign(document.createElement('div'), { className: 'avatar-fallback', textContent: 'VHM' }));
});

function renderMarqueeContent(item, readyPromises) {
  if (!item.logo) {
    const span = document.createElement('span');
    span.className = 'marquee-item';
    span.textContent = item.name;
    return span;
  }
  const img = document.createElement('img');
  img.className = 'marquee-logo';
  img.alt = item.name;
  readyPromises.push(new Promise(resolve => {
    img.onload = resolve;
    img.onerror = () => {
      const span = document.createElement('span');
      span.className = 'marquee-item';
      span.textContent = item.name;
      img.replaceWith(span);
      resolve();
    };
  }));
  img.src = item.logo;
  return img;
}

function renderMarqueeItem(item, readyPromises) {
  const content = renderMarqueeContent(item, readyPromises);
  if (!item.url) return content;
  const link = document.createElement('a');
  link.className = 'marquee-link';
  link.href = item.url;
  link.target = '_blank';
  link.rel = 'noopener noreferrer';
  link.appendChild(content);
  return link;
}

async function loadMarquee(url, trackId, copies = 3) {
  const track = document.getElementById(trackId);
  try {
    const res = await fetch(url);
    const items = await res.json();
    items.sort((a, b) => (b.year || 0) - (a.year || 0));
    const readyPromises = [];
    let secondCopyIndex = 0;
    for (let c = 0; c < copies; c++) {
      if (c === 1) secondCopyIndex = track.children.length;
      items.forEach(item => track.appendChild(renderMarqueeItem(item, readyPromises)));
    }
    // Wait for every logo (all copies) to settle its layout width before
    // starting the loop, otherwise late-loading images resize the track
    // mid-animation and the loop point skips ("saltitos").
    await Promise.all(readyPromises);
    // A flat -50% is only exact when the track's width divides evenly by
    // the (N-1)-gap vs N-gap difference between one set and two; with a
    // `gap` between items that's off by half a gap, which is the other
    // cause of the skip. Measure the real pixel distance from the start
    // of the first copy to the start of the second instead — that's the
    // loop distance regardless of how many extra copies pad the track.
    const shift = track.children[secondCopyIndex].offsetLeft;
    track.style.setProperty('--marquee-shift', `-${shift}px`);
    track.classList.add('is-ready');
  } catch (err) {
    track.closest('.marquee').style.display = 'none';
  }
}

loadMarquee('clients/agencies.json', 'agencies-track');
loadMarquee('clients/clients.json', 'clients-track');
